# Git 工具

## WinGitLang.sh

Windows for Git 语言包安装脚本

终端管理员

```shell
"C:\Program Files\Git\bin\bash.exe" WinGitLang.sh
# 或设置语言
"C:\Program Files\Git\bin\bash.exe" WinGitLang.sh zh_CN
```

## WinGitLang.ps1

启动 “Windows for Git 语言包安装脚本” 的脚本

Powershell 管理员

```shell
# 可选参数
$language = "zh_CN"
$gitLanguageBashUrl = "https://xkk1.github.io/code/shell/git/WinGitLang.sh"
# 下载执行脚本
irm https://xkk1.github.io/code/shell/git/WinGitLang.ps1 | iex
```

或设置参数的本地执行，需要添加执行策略 `Set-ExecutionPolicy RemoteSigned`

```shell
.\WinGitLang.ps1 -lang "zh_CN" -url "https://xkk1.github.io/code/shell/git/WinGitLang.sh"
```
