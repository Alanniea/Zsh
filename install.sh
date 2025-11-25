#!/usr/bin/env bash
set -e

menu() {
    echo "==============================="
    echo "   🌟 Zsh Minimal Neo（升级不丢历史版）🌟"
    echo "==============================="
    echo "1) 安装"
    echo "2) 卸载"
    echo "3) 退出"
    echo -n "选择: "
    read -r choice
}

#################################
# 🗑 卸载
#################################
uninstall() {
    echo "🗑 删除定制..."
    rm -rf ~/.zinit ~/.p10k.zsh
    [[ -f ~/.zsh_history ]] && chmod 600 ~/.zsh_history
    [[ -f ~/.zshrc.bak ]] && mv ~/.zshrc.bak ~/.zshrc
    echo "✔ 卸载完毕"
    exit 0
}

#################################
# 📦 安装依赖
#################################
install_packages() {
    echo "📦 安装依赖..."
    if command -v apt >/dev/null; then
        sudo apt update
        sudo apt install -y zsh git curl fzf wget fonts-powerline bat || true
        command -v batcat >/dev/null && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        sudo apt install -y eza || true
    elif command -v pacman >/dev/null; then
        sudo pacman -Sy --noconfirm zsh git curl wget fzf eza bat
    elif command -v dnf >/dev/null; then
        sudo dnf install -y zsh git curl wget fzf eza bat
    elif command -v brew >/dev/null; then
        brew install zsh git curl fzf eza bat
    elif command -v pkg >/dev/null; then
        pkg install -y zsh git curl fzf eza bat
    fi
}

#################################
# 🎨 写 p10k
#################################
write_p10k() {
cat > ~/.p10k.zsh <<'EOF'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time)
POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0.3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_middle
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
EOF
}

#################################
# 🔥【核心】历史永久化 + 所有历史实时写入
#################################
write_history_config() {
cat << 'EOF'
###########################################
# 🔥 永久保存历史（再也不会丢失）
###########################################
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=500000
export SAVEHIST=500000

# SSH断开也实时写入
setopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME

# 多终端共享历史
setopt SHARE_HISTORY

# 不要重复
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# 保存时间戳
setopt EXTENDED_HISTORY
###########################################
EOF
}

#################################
# 🔧 修复 compaudit
#################################
fix_compaudit() {
    echo "🔧 修复 compaudit..."
    chmod 600 ~/.zsh_history 2>/dev/null || true
    [[ -f ~/.zshrc ]] && chmod 644 ~/.zshrc
    [[ -f ~/.p10k.zsh ]] && chmod 644 ~/.p10k.zsh
    [[ -d ~/.zinit ]] && chmod -R go-w ~/.zinit
    compaudit | xargs chmod g-w,o-w || true
    echo "✔ 权限已修复"
}

#################################
# 🚀 安装流程
#################################
install_zsh() {
    install_packages

    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    mkdir -p ~/.zinit
    git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

cat > ~/.zshrc <<'EOF'
# ========== 🔥历史永久化配置（放最前面） ==========
EOF

write_history_config >> ~/.zshrc

cat >> ~/.zshrc <<'EOF'

# ========== Zinit ==========
source ~/.zinit/bin/zinit.zsh

# 主题
zinit depth"1" light-mode for romkatv/powerlevel10k

# p10k 配置
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 插件
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair
zinit light Aloxaf/fzf-tab
bindkey '^I' fzf-tab-complete

# 常用
setopt autocd
alias ll='eza -lah --icons'
alias cat='bat --style=plain'
EOF

    write_p10k
    fix_compaudit

    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🎉 完成！现在进入 zsh ..."
    sleep 1
    exec zsh
}

while true; do
    menu
    case "$choice" in
        1) install_zsh ;;
        2) uninstall ;;
        3) exit 0 ;;
        *) echo "输入错误" ;;
    esac
done
