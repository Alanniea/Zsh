#!/usr/bin/env bash
set -e

#################################
# 🌟 Zsh Minimal Neo — Single-line + Command Time + Autopair + Auto Fix compinit
#################################

menu() {
    echo "==============================="
    echo "   🌟 Zsh Minimal Neo (Single-line + Command Time + Autopair) 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 极简未来风（单行 + 命令耗时 + autopair + auto fix compinit）"
    echo "2) 卸载 Zsh 定制"
    echo "3) 退出"
    echo -n "请选择 [1-3]: "
    read -r choice
}

#################################
# 🗑 卸载
#################################
uninstall() {
    echo "🚨 开始卸载 Zsh 定制..."

    [[ -d ~/.zinit ]] && rm -rf ~/.zinit
    [[ -f ~/.p10k.zsh ]] && rm -f ~/.p10k.zsh
    [[ -f ~/.zshrc ]] && rm -f ~/.zshrc
    [[ -f ~/.zshrc.bak ]] && mv ~/.zshrc.bak ~/.zshrc

    if command -v chsh >/dev/null 2>&1; then
        chsh -s "$(command -v bash)" || true
    fi

    echo "✅ 卸载完成！"
    exit 0
}

#################################
# 📦 安装依赖
#################################
install_packages() {
    echo "📦 安装依赖..."

    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y zsh git curl wget fzf fonts-powerline bat || true
        command -v batcat >/dev/null && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        sudo apt install -y eza || true

    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --needed --noconfirm zsh git curl wget fzf eza bat

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh git curl wget fzf eza bat

    elif command -v brew >/dev/null 2>&1; then
        brew install zsh git curl fzf eza bat

    elif command -v pkg >/dev/null 2>&1; then
        pkg install -y zsh git curl fzf eza bat

    else
        echo "❌ 不支持的包管理器，请手动安装 zsh/git/fzf/bat/eza"
        exit 1
    fi
}

#################################
# 🎨 写 Single-line Minimal Neo + 命令耗时 + autopair
#################################
write_p10k() {
    echo "📝 写入 Single-line Minimal Neo ~/.p10k.zsh (Command Time + Autopair)"

cat > ~/.p10k.zsh <<'EOF'
# ===============================
# Minimal Neo — Single-line + 命令耗时 + autopair
# ===============================

# instant prompt
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# 单行布局
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time)

POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""

# 目录显示
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

# Git 显示
POWERLEVEL9K_VCS_GIT_ICON=' '
POWERLEVEL9K_VCS_SHOW_CHANGED_IN_PAREN=false
POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true

# 状态
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR=true

# 命令执行耗时阈值
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0.5
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=false

# 极简间距
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
EOF
}

#################################
# 🔧 自动修复 compinit 权限
#################################
fix_compinit_permissions() {
    echo "🔧 修复 compinit 不安全文件权限..."
    [[ -f ~/.zshrc ]] && chmod 644 ~/.zshrc
    [[ -d ~/.zinit ]] && chmod -R go-w ~/.zinit
    compaudit | xargs chmod g-w,o-w || true
}

#################################
# 🚀 安装流程
#################################
install_zsh() {
    echo "🚀 安装 Minimal Neo（单行 + 命令耗时 + autopair + auto fix compinit）..."

    install_packages

    echo "⚡ 安装 zinit..."
    if [[ ! -d ~/.zinit ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    fi

    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    echo "📝 写入新的 ~/.zshrc"

cat > ~/.zshrc <<'EOF'
export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color

# zinit 管理器
source ~/.zinit/bin/zinit.zsh

# powerlevel10k
zinit depth"1" light-mode for romkatv/powerlevel10k

# 加载 single-line + 命令耗时 p10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 插件
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair   # 自动括号配对
zinit light Aloxaf/fzf-tab
bindkey '^I' fzf-tab-complete

# 别名
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat --style=plain'

setopt autocd
setopt correct
setopt hist_ignore_all_dups
setopt share_history
EOF

    write_p10k
    fix_compinit_permissions

    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🎉 安装完成！已自动修复 compinit 权限并 exec zsh，进入单行 Minimal Neo + 命令耗时 + autopair 环境。"
    sleep 1

    exec zsh
}

#################################
# 主菜单
#################################
while true; do
    menu
    case "$choice" in
        1) install_zsh ;;
        2) uninstall ;;
        3) exit 0 ;;
        *) echo "❌ 无效输入" ;;
    esac
done
