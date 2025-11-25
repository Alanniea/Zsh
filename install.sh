#!/usr/bin/env bash
set -e

#################################
# 🌟 Zsh 最强定制 — Minimal Neo
#################################

menu() {
    echo "==============================="
    echo "   🌟 Zsh Minimal Neo 2025 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 极简未来风（自动 exec zsh）"
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
# 📦 依赖
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
# 🎨 写 Minimal Neo 主题
#################################
write_p10k() {
    echo "📝 写入 Minimal Neo ~/.p10k.zsh"

cat > ~/.p10k.zsh <<'EOF'
# ===============================
#   Minimal Neo — 极简未来风主题
# ===============================

# 极速 instant prompt
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# 极简布局：左 → dir + git
#           右 → exit status + time
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

# 单线条未来风
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{cyan}┌─%f "
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{cyan}└─❯%f "

# 目录样式：短路径 + 极简箭头
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"

# Git 显示
POWERLEVEL9K_VCS_GIT_ICON=' '
POWERLEVEL9K_VCS_LOADING_TEXT=""
POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true

# 成功与失败状态
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR=true

# 时间
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"

# 字体不影响：自动 fallback
POWERLEVEL9K_ICON_PADDING=none

# 真·极简
POWERLEVEL9K_SHOW_RULER=false
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
EOF
}

#################################
# 🚀 安装 Zsh 定制
#################################
install_zsh() {
    echo "🚀 安装 Minimal Neo 主题 Zsh..."

    install_packages

    echo "⚡ 安装 zinit..."
    if [[ ! -d ~/.zinit ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    fi

    # 备份旧 zshrc
    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    #################################
    # 写入极简 ~/.zshrc
    #################################
    echo "📝 写入新的 ~/.zshrc"

cat > ~/.zshrc <<'EOF'
export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color

# Zinit
source ~/.zinit/bin/zinit.zsh

# Powerlevel10k
zinit depth"1" light-mode for romkatv/powerlevel10k

# 极简 future 风 p10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 插件
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# FZF Tab
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

    # 写 Neo 主题
    write_p10k

    # 默认 shell → zsh
    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🎉 完成安装！现在自动 exec zsh 启动 Minimal Neo！"
    exec zsh
}

#################################
# 🔧 主菜单
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
