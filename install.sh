#!/bin/bash

# =================================================================
# 脚本名称: install_zsh_zinit.sh
# 描述: 自动安装 Zsh, Zinit, P10k 及常用插件，并修复历史记录保存问题
# =================================================================

set -e

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}开始自动配置 Zsh 环境...${NC}"

# 1. 环境检测与基础包安装
detect_os_and_install_dependencies() {
    echo -e "${GREEN}[1/5] 检查依赖项...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            sudo apt-get update && sudo apt-get install -y zsh git curl wget
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y zsh git curl wget
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        command -v brew &>/dev/null || { echo -e "${RED}请先安装 Homebrew${NC}"; exit 1; }
        brew install zsh git curl wget
    fi
}

# 2. 安装 Zinit
install_zinit() {
    echo -e "${GREEN}[2/5] 安装 Zinit 插件管理器...${NC}"
    ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
    if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    fi
}

# 3. 配置 .zshrc (包含历史记录逻辑)
configure_zshrc() {
    echo -e "${GREEN}[3/5] 配置 .zshrc 文件并启用历史记录...${NC}"
    [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"

    cat << 'EOF' > "$HOME/.zshrc"
# ==========================================
# 历史记录配置 (修复 ~/.zsh_history 不存在的问题)
# ==========================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# 历史记录优化选项
setopt EXTENDED_HISTORY      # 记录时间戳
setopt SHARE_HISTORY         # 多个终端会话共享历史
setopt HIST_EXPIRE_DUPS_FIRST # 优先删除重复的历史
setopt HIST_IGNORE_DUPS       # 不记录连续重复的命令
setopt HIST_IGNORE_ALL_DUPS   # 删除旧的重复命令
setopt HIST_FIND_NO_DUPS      # 搜索时不显示重复
setopt HIST_IGNORE_SPACE      # 不记录以空格开头的命令
setopt HIST_SAVE_NO_DUPS      # 保存时不保存重复
setopt HIST_REDUCE_BLANKS     # 移除多余空白

# ==========================================
# Zinit 初始化
# ==========================================
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_libs_functions} )) && _libs_functions+=( _zinit )

# 加载 P10k 主题
zinit ice depth"1"; zinit light romkatv/powerlevel10k

# 加载插件
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# 快捷键与补全设置
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

# 4. 更改默认 Shell
set_default_shell() {
    echo -e "${GREEN}[4/5] 设置 Zsh 为默认 Shell...${NC}"
    [ "$SHELL" != "$(which zsh)" ] && chsh -s $(which zsh)
}

detect_os_and_install_dependencies
install_zinit
configure_zshrc
set_default_shell

echo -e "${GREEN}配置完成！请执行 'exec zsh' 或重新打开终端。${NC}"

