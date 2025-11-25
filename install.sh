#!/usr/bin/env bash
set -e

# ================================
# 🌟 Zsh 最强定制 2025（自动 p10k 配置 + 自动重载） 
# ================================

menu() {
    echo "==============================="
    echo "   🌟 Zsh 最强定制 2025 🌟"
    echo "==============================="
    echo "1) 安装 Zsh 最强定制（含已配置主题，安装完成自动 exec zsh）"
    echo "2) 卸载 Zsh 最强定制"
    echo "3) 退出"
    echo -n "请选择 [1-3]: "
    read -r choice
}

uninstall() {
    echo "🚨 开始卸载 Zsh 最强定制..."

    if command -v chsh >/dev/null 2>&1; then
        echo "🔧 恢复系统默认 Shell（bash）..."
        chsh -s "$(command -v bash)" || true
    fi

    [[ -d ~/.zinit ]] && { echo "🗑 删除 zinit..."; rm -rf ~/.zinit; }
    [[ -f ~/.p10k.zsh ]] && { echo "🗑 删除 ~/.p10k.zsh"; rm -f ~/.p10k.zsh; }
    if [[ -f ~/.zshrc ]]; then
        echo "🗑 删除当前 ~/.zshrc"
        rm -f ~/.zshrc
    fi
    [[ -f ~/.zshrc.bak ]] && { echo "♻️ 恢复 ~/.zshrc.bak → ~/.zshrc"; mv ~/.zshrc.bak ~/.zshrc; }

    echo "✅ 卸载完成！"
    exit 0
}

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

# 尝试在 Linux/macOS 上自动安装 Meslo Nerd Font（用于 p10k 图标）
install_meslo_nerd_font() {
    echo "🎯 尝试安装 Meslo Nerd Font（用于 Powerlevel10k 图标）..."
    # macOS (Homebrew)
    if command -v brew >/dev/null 2>&1; then
        if brew tap | grep -q "homebrew/cask-fonts"; then
            brew install --cask font-meslo-lg-nerd-font || true
            echo "✅ macOS: 尝试通过 Homebrew 安装 Meslo 字体（如已安装会跳过）"
            return
        else
            brew tap homebrew/cask-fonts || true
            brew install --cask font-meslo-lg-nerd-font || true
            echo "✅ macOS: 尝试通过 Homebrew 安装 Meslo 字体"
            return
        fi
    fi

    # Linux: 下载并安装到 ~/.local/share/fonts (用户级)
    if [[ "$(uname -s)" == "Linux" ]]; then
        mkdir -p ~/.local/share/fonts
        base="https://github.com/romkatv/powerlevel10k-media/raw/master"
        files=(
            "MesloLGS NF Regular.ttf"
            "MesloLGS NF Bold.ttf"
            "MesloLGS NF Italic.ttf"
            "MesloLGS NF Bold Italic.ttf"
        )
        for f in "${files[@]}"; do
            url="$base/$f"
            out="$HOME/.local/share/fonts/$f"
            if [[ ! -f "$out" ]]; then
                echo "↓ 下载 $f"
                curl -fsSL "$url" -o "$out" || true
            fi
        done
        # 刷新字体缓存（如果可用）
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f -v || true
        fi
        echo "✅ Linux: 已尝试安装 Meslo 字体到 ~/.local/share/fonts（若失败，请手动安装 Nerd Font）"
    fi
}

# 写入预配置的 ~/.p10k.zsh（简洁、好看、开箱即用）
write_p10k() {
    echo "📝 写入预配置 ~/.p10k.zsh（已设好常用段与样式）"
cat > ~/.p10k.zsh <<'P10K_EOF'
# ~/.p10k.zsh -- 自动预配置（非交互）
# 如果你想用向导重新生成：运行 `p10k configure`

# Instant prompt for faster startup (默认缓存目录)
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# 基本布局：左侧显示 user/dir/vcs，右侧显示状态/时间/后台任务
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)

# 视觉风格
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{blue}╭─%f "
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{blue}╰─%f "

# 细节：短化目录显示、VCS 显示设置
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
typeset -g POWERLEVEL9K_VCS_GIT_ICON=' '     # 需要 Nerd Font
typeset -g POWERLEVEL9K_VCS_MAX_SYNC_AGE=5

# 轻量化：命令时间显示阈值（超过 3s 才显示）
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3

# 状态颜色（成功/失败）
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_ERROR=true

# 右侧时间格式
typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"

# Minimal icons when no Nerd Font
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

# Prompt symbol
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{cyan}╭─%f "
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{cyan}╰─%f "

# 假如你想改回向导生成的配置，运行：p10k configure
P10K_EOF
}

install_zsh() {
    echo "🚀 安装 Zsh 最强定制（含预配置主题）..."

    install_packages

    echo "⚡ 安装 zinit..."
    if [[ ! -d ~/.zinit ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin || true
    fi

    # 备份旧 zshrc
    if [[ -f ~/.zshrc ]]; then
        echo "📦 备份现有 ~/.zshrc → ~/.zshrc.bak"
        mv ~/.zshrc ~/.zshrc.bak
    fi

    # 写入 zshrc（引用 p10k）
    echo "📝 写入新的 ~/.zshrc（包含 zinit 与 p10k）"
cat > ~/.zshrc <<'ZSHRC_EOF'
# =============================
# 🚀 最强 Zsh 定制（2025 版）
# =============================

export ZSH_DISABLE_COMPFIX=true
export TERM=xterm-256color
export EDITOR=vim

# 加载 zinit
source ~/.zinit/bin/zinit.zsh

# 预装 Powerlevel10k（通过 zinit）
zinit depth"1" light-mode for romkatv/powerlevel10k

# 预加载 p10k 配置（若存在）
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh 2>/dev/null || true

# 性能插件
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair

# FZF + fzf-tab
zinit light Aloxaf/fzf-tab
bindkey '^I' fzf-tab-complete

# 历史记录增强
HISTFILE=~/.zsh_history
SAVEHIST=200000
HISTSIZE=200000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

# 别名
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat --style=plain'

# Zsh 行为优化
setopt autocd
setopt correct
setopt complete_in_word
setopt auto_pushd
setopt pushd_ignore_dups
setopt interactivecomments
ZSHRC_EOF

    # 写入 p10k 配置文件
    write_p10k

    # 尝试自动装 Meslo Nerd Font（非必须）
    install_meslo_nerd_font

    # 设置默认 shell
    if command -v chsh >/dev/null 2>&1; then
        echo "🔧 设置 zsh 为默认 shell..."
        chsh -s "$(command -v zsh)" || true
    fi

    echo
    echo "🎉 安装完成！脚本将自动用 exec zsh 重载为新 shell。"
    echo "提示：若你想用 p10k 向导重新生成个人化主题，请运行： p10k configure"
    echo

    # 自动重载：优先 exec zsh；若 exec 失败则回退 source ~/.zshrc
    if command -v zsh >/dev/null 2>&1; then
        echo "🔄 正在重载到 zsh（exec zsh）…"
        exec zsh
    fi

    if [[ -f ~/.zshrc ]]; then
        echo "⚠️ exec zsh 未生效，退回为 source ~/.zshrc"
        # shellcheck disable=SC1090
        source ~/.zshrc
    fi

    exit 0
}

# 主循环
while true; do
    menu
    case "$choice" in
        1) install_zsh ;;
        2) uninstall ;;
        3) echo "👋 退出"; exit 0 ;;
        *) echo "❌ 无效选项，请输入 1~3";;
    esac
done
