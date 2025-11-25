#!/usr/bin/env bash
set -e

# ================================
# 🍀 交互菜单 - 自动 reload 版
# ================================

menu() {
    echo "==============================="
    echo "   🌟 Zsh 最强定制 2025 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 最强定制（安装后自动重载 exec zsh）"
    echo "2) 卸载 Zsh 最强定制"
    echo "3) 退出"
    echo -n "请选择 [1-3]: "
    read -r choice
}

# ================================
# 0. 卸载函数
# ================================
uninstall() {
    echo "🚨 开始卸载 Zsh 最强定制..."

    # 恢复默认 shell（若可用）
    if command -v chsh >/dev/null 2>&1; then
        echo "🔧 恢复系统默认 Shell（bash）..."
        chsh -s "$(command -v bash)" || true
    fi

    # 删除 zinit
    if [[ -d ~/.zinit ]]; then
        echo "🗑 删除 zinit..."
        rm -rf ~/.zinit
    fi

    # 删除 p10k 配置
    [[ -f ~/.p10k.zsh ]] && { echo "🗑 删除 p10k 配置..."; rm -f ~/.p10k.zsh; }

    # 删除当前 zshrc
    if [[ -f ~/.zshrc ]]; then
        echo "🗑 删除当前 ~/.zshrc"
        rm -f ~/.zshrc
    fi

    # 恢复备份
    if [[ -f ~/.zshrc.bak ]]; then
        echo "♻️ 恢复 ~/.zshrc.bak → ~/.zshrc"
        mv ~/.zshrc.bak ~/.zshrc
    fi

    echo "✅ 卸载完成！"
    exit 0
}

# ================================
# 1. 安装依赖
# ================================
install_packages() {
    echo "📦 开始安装依赖..."
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
        pkg install -y zsh git curl fzf bat eza

    else
        echo "❌ 无法识别包管理器，请手动安装 zsh/git/curl/fzf/bat/eza"
        exit 1
    fi
}

# ================================
# 2. 安装函数（安装后会自动 exec zsh）
# ================================
install_zsh() {
    echo "🚀 安装 Zsh 最强定制 2025..."

    install_packages

    echo "⚡ 安装 zinit..."
    if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    fi

    if [[ -f ~/.zshrc ]]; then
        echo "📦 备份现有 ~/.zshrc → ~/.zshrc.bak"
        mv ~/.zshrc ~/.zshrc.bak
    fi

    echo "📝 写入新的 ~/.zshrc"

cat > ~/.zshrc << 'EOF'
# =============================
# 🚀 最强 Zsh 定制（2025 版）
# =============================

export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color
export EDITOR=vim

# -----------------------------
# 1. 加载 zinit
# -----------------------------
source ~/.zinit/bin/zinit.zsh

# -----------------------------
# 2. Powerlevel10k
# -----------------------------
zinit depth"1" light-mode for romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] && p10k configure
source ~/.p10k.zsh 2>/dev/null || true

# -----------------------------
# 3. 性能插件
# -----------------------------
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair

# -----------------------------
# 4. FZF + fzf-tab
# -----------------------------
zinit light Aloxaf/fzf-tab
bindkey '^I' fzf-tab-complete

# -----------------------------
# 5. 历史记录增强
# -----------------------------
HISTFILE=~/.zsh_history
SAVEHIST=200000
HISTSIZE=200000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

# -----------------------------
# 6. 别名
# -----------------------------
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat --style=plain'

# -----------------------------
# 7. Zsh 行为优化
# -----------------------------
setopt autocd
setopt correct
setopt complete_in_word
setopt auto_pushd
setopt pushd_ignore_dups
setopt interactivecomments
EOF

    if command -v chsh >/dev/null 2>&1; then
        echo "🔧 设置默认 shell 为 zsh..."
        chsh -s "$(command -v zsh)" || true
    fi

    echo
    echo "🎉 安装完成！脚本将自动用 exec zsh 重载为新 shell。"
    echo "（如果你不希望自动重载，下一次运行脚本请选择退出并手动 source/exec）"
    echo

    # 自动重载：优先 exec zsh；若 exec 失败则回退为 source
    if command -v zsh >/dev/null 2>&1; then
        echo "🔄 正在重载为 zsh（exec zsh）…"
        exec zsh
        # exec 成功不会返回；若失败，会继续执行下面的回退
    fi

    # 回退（极少用到）：当没有 zsh 可执行或 exec 失败时
    if [[ -f ~/.zshrc ]]; then
        echo "⚠️ exec zsh 未能替换 shell，改为 source ~/.zshrc"
        # shellcheck disable=SC1090
        source ~/.zshrc
    fi

    exit 0
}

# ================================
# 🚀 主逻辑：菜单循环
# ================================
while true; do
    menu
    case "$choice" in
        1) install_zsh ;;
        2) uninstall ;;
        3) echo "👋 退出"; exit 0 ;;
        *) echo "❌ 无效选项，请输入 1~3";;
    esac
done
