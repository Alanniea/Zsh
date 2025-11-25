#!/usr/bin/env bash
set -e

#################################
# 🌟 Zsh Minimal Neo — Single-line
#################################

menu() {
    echo "==============================="
    echo "   🌟 Zsh Minimal Neo (Single-line) 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 极简未来风（单行模式，自动 exec zsh）"
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
# 📦 依赖安装
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
# 🎨 写 Single-line Minimal Neo 主题
#################################
write_p10k() {
    echo "📝 写入 Single-line Minimal Neo ~/.p10k.zsh"

cat > ~/.p10k.zsh <<'EOF'
# ===============================
#   Minimal Neo — Single-line 模式
# ===============================

# instant prompt 加速
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# 单行布局：左 → dir vcs ; 右 → status time
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

# 关键：单行，不换行显示 prompt
POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

# 去掉多行前缀（单行不需要）
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""

# 目录显示：尽量短
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

# Git 显示（极简）
POWERLEVEL9K_VCS_GIT_ICON=' '
POWERLEVEL9K_VCS_SHOW_CHANGED_IN_PAREN=false
POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true

# 状态（仅显示失败时的红色标记）
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR=true

# 时间显示（右侧）
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"

# 极简间距与符号
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

# 如果想恢复完整向导：运行 p10k configure
EOF
}

#################################
# 🚀 安装主流程（含自动 exec zsh）
#################################
install_zsh() {
    echo "🚀 安装 Minimal Neo（单行）..."

    install_packages

    echo "⚡ 安装 zinit..."
    if [[ ! -d ~/.zinit ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    fi

    # 备份旧 zshrc
    [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak

    #################################
    # 写入极简 ~/.zshrc（单行版）
    #################################
    echo "📝 写入新的 ~/.zshrc"

cat > ~/.zshrc <<'EOF'
export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color

# zinit 管理器
source ~/.zinit/bin/zinit.zsh

# powerlevel10k（via zinit）
zinit depth"1" light-mode for romkatv/powerlevel10k

# 加载我们写好的 single-line p10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 必要效率插件（轻量）
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# fzf-tab（可选）
zinit light Aloxaf/fzf-tab
bindkey '^I' fzf-tab-complete

# 常用别名
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat --style=plain'

setopt autocd
setopt correct
setopt hist_ignore_all_dups
setopt share_history
EOF

    # 写入 p10k 单行配置
    write_p10k

    # 尝试设置 zsh 为默认 shell（若支持）
    command -v chsh >/dev/null && chsh -s "$(command -v zsh)" || true

    echo "🎉 安装完成！即将自动 exec zsh，进入单行 Minimal Neo 环境。"
    echo "（若你有重要子进程请先终止它们）"
    sleep 1

    # 自动重载为 zsh（替换当前 shell）
    if command -v zsh >/dev/null 2>&1; then
        exec zsh
    fi

    # 若 exec 失败则 fallback 为 source
    if [[ -f ~/.zshrc ]]; then
        echo "⚠️ exec zsh 未成功，改为 source ~/.zshrc"
        # shellcheck disable=SC1090
        source ~/.zshrc
    fi

    exit 0
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
