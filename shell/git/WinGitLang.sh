#!/usr/bin/bash
# Author: xkk1
# 描述：小喾苦 Git for Windows 语言包安装 Bash 脚本（需管理员权限）
# 注意：请以 Git Bash（管理员权限）运行此脚本
# "C:\Program Files\Git\bin\bash.exe" WinGit_zh-CN.sh

# 参考：https://zhuanlan.zhihu.com/p/681521193

echo "🔧 小喾苦 Git for Windows 语言包安装 Bash 脚本"

# -------------------------- 语言包下载 --------------------------
# 语言默认简体中文
if [ -z "${language}" ]; then
    language="zh_CN"
fi
# 命令行参数的第一个参数设置语言
if [ ! -z "$1" ]; then
    language=$1
    echo "🌐 指定语言：$language"
else
    echo "🌐 默认语言：$language"
fi
# 构造语言包文件名、下载链接
language_file="$language.po"
language_file_URL="https://github.com/git-for-windows/git/raw/refs/heads/main/po/$language_file"
echo "⬇️ 正在下载语言包： $language_file"
echo "🔗 下载链接：$language_file_URL"
# wget language_file_URL -O zh_CN.po
# 使用curl下载（更适合Windows环境）
curl -L -o $language_file $language_file_URL
# 下载结果校验
if [ $? -ne 0 ] || [ ! -s "$language_file" ]; then
    echo "❌ 下载失败：网络问题或文件损坏"
    exit 1
fi
echo "✅ 语言包下载完成（$(du -h "$language_file" | awk '{print $1}')）"


# -------------------------- 环境检查 --------------------------
# 检查 msgfmt 工具是否存在（生成 mo 文件必需）
# 确保 gettext 工具在 PATH 中
PATH="/c/Program Files (x86)/GnuWin32/bin:$PATH"
if ! command -v msgfmt &>/dev/null; then
    echo "⚠️ gettext 工具缺失：未找到 msgfmt 命令"
    echo "🔄 尝试安装 winget install GnuWin32.GetText"
    winget install GnuWin32.GetText
    if [ $? -ne 0 ]; then
        echo "❌ 安装失败：请手动安装 GetText 或检查网络连接"
        exit 1
    else
        echo "✅ gettext 工具安装成功"
    fi
fi

# -------------------------- 生成MO文件 --------------------------
echo -e "🔄 正在生成二进制语言包（msgfmt -o git.mo \"$language_file\"）..."
if ! msgfmt -o git.mo "$language_file"; then
    echo "❌ 生成失败：语言包格式错误或 msgfmt 异常"
    exit 1
fi
if [ ! -s git.mo ]; then
    echo "❌ 生成失败：生成的 git.mo 文件为空或损坏"
    exit 1
fi
echo "✅ MO 文件生成成功：git.mo $(ls -lh git.mo | awk '{print $5}')"

# -------------------------- 部署到系统目录 --------------------------
LC_MESSAGES_dir="/mingw64/share/locale/$language/LC_MESSAGES"
LC_MESSAGES_file="$LC_MESSAGES_dir/git.mo"

# 检查目录是否存在
echo "📂 正在检查目录是否存在：${LC_MESSAGES_dir}"
if [ ! -d "$LC_MESSAGES_dir" ]; then
    # 创建多级目录（-p自动创建缺失父目录）
    echo -e "⚠️ 目录不存在，正在创建目录：mkdir -vp \"${LC_MESSAGES_dir}\""
    mkdir -vp "$LC_MESSAGES_dir"
    if [ $? -ne 0 ]; then
        echo "❌ 创建目录失败，请检查是否有权限：${LC_MESSAGES_dir}"
        exit 1
    fi
    echo "✅ 目录创建成功：${LC_MESSAGES_dir}"
fi

# 复制文件并校验
echo "📦 正在复制 git.mo 到 ${LC_MESSAGES_file} ..."
if ! cp -v git.mo "$LC_MESSAGES_file"; then
    echo "❌ 复制失败：目标目录无写入权限或路径错误"
    exit 1
fi

# -------------------------- 安装完成提示 --------------------------
echo -e "\n🎉 Git for Windows 语言包 $language_file 安装成功！"
echo "📄 语言包文件：$(realpath "$LC_MESSAGES_file")"

# -------------------------- 清理文件并退出 --------------------------
rm -f git.mo "$language_file"
exit 0
