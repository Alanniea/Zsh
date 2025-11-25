#!/usr/bin/env bash
set -e

#################################
# 🌟 Zsh Minimal Neo — Single-line + Command Time + Autopair + Safe compinit
#################################

menu() {
    echo "==============================="
    echo "   🌟 Zsh Minimal Neo (Single-line + Command Time + Autopair) 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 极简未来风（单行 + 命令耗时 + autopair + 安全 compinit）"
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
# 🎨 写 P10K 配置
#################################
write_p10k() {
    cat > ~/.p10k.zsh <<'EOF'
# Minimal Neo — 单行 + 命令耗时 + autopair
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time)
POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_VCS_GIT_ICON=' '
POWERLEVEL9K_VCS_SHOW_CHANGED_IN_PAREN=false
POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR=true
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0.5
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=false
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
EOF
}

#################################
# 🔧 一键修复 compaudit（彻底版）
#################################
fix_compaudit() {
    echo "🔧 自动修复 compaudit 权限..."
    [[ -f ~/.zshrc ]] && chmod 644 ~/.zshrc
    [[ -f ~/.p10k.zsh ]] && chmod 644 ~/.p10k.zsh
    [[ -d ~/.zinit ]] && chmod -R go-w ~/.zinit
    # 修复其他补全文件
    compaudit | xargs chmod g-w,o-w || true
    echo "✅ 权限修复完成！"
}

#################################
# 🚀 安装流程
#################################
install_zsh() {
    echo "🚀 安装 Minimal Neo（单行 + 命令耗时 + autopair + 安全 compinit）..."
    install_packages

    # 安装 zinit
    if [[ ! -d ~/.zinit ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    fi

    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    # 写入 ~/.zshrc
    cat > ~/.zshrc <<'EOF'
export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color

source ~/.zinit/bin/zinit.zsh

# powerlevel10k
zinit depth"1" light-mode for romkatv/powerlevel10k

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 插件
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair
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
    fix_compaudit

    # 设置默认 shell
    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🎉 安装完成！权限安全，自动 exec zsh 进入单行 Minimal Neo + 命令耗时 + autopair"
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
