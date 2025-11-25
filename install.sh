#!/usr/bin/env bash
set -e

menu() {
    echo
    echo "==============================="
    echo "🌟 Zsh 最强定制（自动主题）🌟"
    echo "==============================="
    echo "1) 安装（自动配置主题 + 自动 reload）"
    echo "2) 卸载"
    echo "3) 退出"
    echo -n "请选择 [1-3]: "
    read -r choice
}

uninstall() {
    echo "🚨 开始卸载 Zsh 最强定制..."

    if command -v chsh >/dev/null 2>&1; then
        chsh -s "$(command -v bash)" || true
    fi

    rm -rf ~/.zinit ~/.p10k.zsh ~/.zshrc
    [[ -f ~/.zshrc.bak ]] && mv ~/.zshrc.bak ~/.zshrc

    echo "✅ 卸载完成"
    exit 0
}

install_packages() {
    echo "📦 安装依赖..."
    if command -v apt >/dev/null; then
        sudo apt update
        sudo apt install -y zsh git curl wget fzf fonts-powerline bat || true
        command -v batcat && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        sudo apt install -y eza || true

    elif command -v pacman >/dev/null; then
        sudo pacman -Sy --needed --noconfirm zsh git curl wget fzf eza bat

    elif command -v dnf >/dev/null; then
        sudo dnf install -y zsh git curl wget fzf eza bat

    elif command -v brew >/dev/null; then
        brew install zsh git curl fzf eza bat

    elif command -v pkg >/dev/null; then
        pkg install -y zsh git curl fzf bat eza
    fi
}

install_zsh() {
    echo "🚀 安装 Zsh 最强定制..."

    install_packages

    echo "⚡ 安装 zinit..."
    mkdir -p ~/.zinit
    [[ ! -d ~/.zinit/bin ]] && git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    # ----------------------------
    # 写入主题文件 ~/.p10k.zsh
    # ----------------------------
cat > ~/.p10k.zsh << 'EOF'
# =============================
# 🎨 Powerlevel10k 完整主题配置
# 自动生成，零交互
# =============================

# 启动速度优化
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# 样式
typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%242F╭─"
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%242F╰▶ "

# 目录样式
typeset -g POWERLEVEL9K_DIR_FOREGROUND=231
typeset -g POWERLEVEL9K_DIR_BACKGROUND=61

# Git
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=82
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=231
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=196

# 命令执行时间
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=220
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2

# 状态
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=0
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=70
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=231
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=196

# 时间
typeset -g POWERLEVEL9K_TIME_FOREGROUND=0
typeset -g POWERLEVEL9K_TIME_BACKGROUND=39
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
EOF

    # ----------------------------
    # 写入 ~/.zshrc
    # ----------------------------
cat > ~/.zshrc << 'EOF'
export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color
export EDITOR=vim

# ========== Zinit ==========
source ~/.zinit/bin/zinit.zsh

# 基础组件
zinit depth"1" light-mode for romkatv/powerlevel10k
source ~/.p10k.zsh

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair
zinit light Aloxaf/fzf-tab

bindkey '^I' fzf-tab-complete

# 历史增强
HISTFILE=~/.zsh_history
SAVEHIST=200000
HISTSIZE=200000
setopt share_history hist_ignore_all_dups hist_reduce_blanks

# 常用
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat --style=plain'
EOF

    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🔄 重载 shell..."
    exec zsh
}

# =================
# 主逻辑循环
# =================
while true; do
    menu
    case "$choice" in
        1) install_zsh ;;
        2) uninstall ;;
        3) exit 0 ;;
        *) echo "❌ 输入 1~3" ;;
    esac
done
