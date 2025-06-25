<#
.SYNOPSIS
    使用 Git Bash 下载并执行 WinGitLang.sh 脚本
.DESCRIPTION
    1. 通过环境变量寻找 Git Bash路径
    2. 下载并执行 WinGitLang.sh
#>

param (
    [string]$lang, # 语言参数，默认为简体中文 "zh_CN"
    [string]$url # Git for Windows 语言包安装 Bash 脚本下载 URL
)

Write-Host "🔧 小喾苦 Git for Windows 语言包自动安装 PowerShell 脚本" -ForegroundColor Green

# -------------------------- 检测是否以管理员身份运行 --------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ 错误：此脚本需要以管理员权限运行！" -ForegroundColor Red
    Write-Host "🖱️ 请右键点击 PowerShell 图标，选择 '以管理员身份运行' 后重试。" -ForegroundColor Yellow
    return
}

# -------------------------- 通过环境变量获取 Git for Windows 安装路径 --------------------------
# 检测 git.exe 是否在环境变量 PATH 中
try {
    $gitExePath = (Get-Command git.exe -ErrorAction Stop).Source
    $gitExeDir = Split-Path -Path $gitExePath -Parent
    # 从 git.exe 路径推导 Git for Windows 路径
    $gitDir = Split-Path -Path $gitExeDir -Parent
    Write-Host "📁 检测到 Git for Windows 安装路径: $gitDir" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未检测到 Git for Windows 安装或 git.exe 不在环境变量 PATH 中" -ForegroundColor Red
    Write-Host "📦 请先安装 Git for Windows 并确保 git.exe 在系统 PATH 环境变量中" -ForegroundColor Yellow
    return
}
# 在 Git for Windows 安装目录中查找 bash.exe
try {
    $gitBashPath = Join-Path -Path $gitDir -ChildPath "bin\bash.exe"
    
    if (-not (Test-Path $gitBashPath)) {
        throw "❌ 在 Git 目录中未找到 bash.exe"
    }
    
    Write-Host "📄 Git Bash 路径: $gitBashPath" -ForegroundColor Cyan
} catch {
    Write-Host "❌ 错误：无法找到 Git Bash 路径 $gitBashPath" -ForegroundColor Red
    Write-Host "📦 请确保 Git for Windows 已正确安装" -ForegroundColor Yellow
    return
}

# -------------------------- 设置环境变量 --------------------------
# 语言默认简体中文
if ([string]::IsNullOrEmpty($language)) {
    $language = "zh_CN"
}
# 如果提供了 lang 参数，则使用该参数
if (-not [string]::IsNullOrEmpty($lang)) {
    $language = $lang
    Write-Host "🌐 指定语言: $language" -ForegroundColor Cyan
} else {
    Write-Host "🌐 默认语言: $language" -ForegroundColor Cyan
}
# 构造完整环境变量值
$languageEnvironmentVariable = "$language.UTF-8"
# 设置环境变量 LANG
$env:LANG = "$languageEnvironmentVariable"
[Environment]::SetEnvironmentVariable("LANG", $languageEnvironmentVariable, [EnvironmentVariableTarget]::User)

# 3. 下载 Git for Windows 语言包安装 Bash 脚本 WinGitLang.sh 到临时文件夹
if ([string]::IsNullOrEmpty($gitLanguageBashUrl)) {
    # 默认下载地址
    $gitLanguageBashUrl = "https://xkk1.github.io/code/shell/git/WinGitLang.sh"
}
# 如果提供了 URL 参数，则使用该 URL
if (-not [string]::IsNullOrEmpty($url)) {
    $gitLanguageBashUrl = $url
}
$gitLanguageBashFileName = "WinGitLang.sh"

# 获取空临时文件夹
function Get-EmptyTempFolder {
    # 获取系统临时目录路径
    $tempParent = [System.IO.Path]::GetTempPath()
    # 生成唯一 GUID 作为子文件夹名（格式：{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}）
    $folderName = [guid]::NewGuid().ToString()
    # 完整临时文件夹路径
    $tempFolder = Join-Path -Path $tempParent -ChildPath $folderName

    # 创建空文件夹（-Force 强制创建，即使父目录不存在）
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null

    # 返回文件夹路径
    return $tempFolder
}
$tempFolder = Get-EmptyTempFolder
$gitLanguageBashFilePath = Join-Path -Path $tempFolder -ChildPath $gitLanguageBashFileName

Write-Host "⬇️ 正在从 URL🔗 下载脚本: $gitLanguageBashUrl" -ForegroundColor Cyan
Write-Host "📂 保存到临时路径: $gitLanguageBashFilePath" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $gitLanguageBashUrl -OutFile $gitLanguageBashFilePath -UseBasicParsing
    
    if (Test-Path $gitLanguageBashFilePath) {
        Write-Host "📄 脚本已成功下载到: $gitLanguageBashFilePath" -ForegroundColor Green
    } else {
        throw "⛓️‍💥 下载失败：文件未找到"
    }
} catch {
    Write-Host "❌ 下载过程中出错: $_" -ForegroundColor Red
    return
}

# -------------------------- 执行脚本 --------------------------
Write-Host "🪜 正在执行 Git Bash 安装 Git 语言包 bash 脚本..." -ForegroundColor Cyan
# 启动 bash.exe 进程，指定要运行的脚本文件，并设置工作目录
# 启动 Git Bash 并传递参数
Start-Process `
    -FilePath $gitBashPath `
    -ArgumentList $gitLanguageBashFilePath, $language `
    -WorkingDirectory $tempFolder `
    -NoNewWindow `
    -Wait
# 清理文件
if (Test-Path $tempFolder) {
    Remove-Item -Path $tempFolder -Recurse -Force
    Write-Host "🗑️ 临时文件夹已清理: $tempFolder"
}
