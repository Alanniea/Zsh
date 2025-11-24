#!/usr/bin/env bash
set -e

ACTION="$1"

# ============================
# 0. 函数：卸载 Zsh 最强定制
# ============================

uninstall() {
    echo "🚨 开始卸载 Zsh 最强定制..."

    # 恢复默认 shell
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
    [[ -f ~/.p10k.zsh ]] && rm -f ~/.p10k.zsh

    # 删除当前 zshrc，但保留用户备份
    if [[ -f ~/.zshrc ]]; then
        echo "📁 删除当前 .zshrc"
        rm -f ~/.zshrc
    fi

    # 恢复旧 zshrc
    if [[ -f ~/.zshrc.bak ]]; then
        echo "♻️ 恢复你的旧 zshrc"
        mv ~/.zshrc.bak ~/.zshrc
    fi

    echo "✅ 卸载完成！请重新打开终端。"
    exit 0
}

# 如果用户输入 uninstall → 执行卸载
if [[ "$ACTION" == "uninstall" ]]; then
    uninstall
fi


# ============================
# 1. 安装依赖
# ============================

echo "🚀 开始安装《Zsh 最强定制 2025》……"

install_packages() {
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
        echo "❌ 无法识别包管理器，请手动安装：zsh git curl fzf bat eza"
        exit 1
    fi
}

install_packages


# ============================
# 2. 安装 zinit
# ============================

echo "⚡ 安装 zinit..."
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
    mkdir -p ~/.zinit
    git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi


# ============================
# 3. 备份旧配置
# ============================

if [[ -f ~/.zshrc ]]; then
    echo "📦 备份现有 ~/.zshrc → ~/.zshrc.bak"
    mv ~/.zshrc ~/.zshrc.bak
fi


# ============================
# 4. 写入最强 zshrc
# ============================

echo "📝 写入新的 .zshrc"

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


# ============================
# 5. 设置默认 Shell
# ============================

if command -v chsh >/dev/null 2>&1; then
    echo "🔧 将 zsh 设为默认 shell..."
    chsh -s "$(command -v zsh)" || true
fi

echo
echo "🎉 安装完成！重新打开终端即可体验最强 Zsh。"
echo "💡 卸载命令： bash install.sh uninstall"
