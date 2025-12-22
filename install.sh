#!/bin/bash

# =================================================================
# 脚本名称: install_zsh_zinit.sh
# 描述: 自动安装 Zsh, Zinit, P10k 及常用插件
# 包含: autosuggestions, syntax-highlighting, completions, history-search
# =================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}开始自动配置 Zsh 环境...${NC}"

# 1. 环境检测与基础包安装
detect_os_and_install_dependencies() {
    echo -e "${GREEN}[1/5] 检查依赖项...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            sudo apt-get update
            sudo apt-get install -y zsh git curl wget
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y zsh git curl wget
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &>/dev/null; then
            echo -e "${RED}未找到 Homebrew，请先安装 Homebrew。${NC}"
            exit 1
        fi
        brew install zsh git curl wget
    fi
}

# 2. 安装 Zinit
install_zinit() {
    echo -e "${GREEN}[2/5] 安装 Zinit 插件管理器...${NC}"
    if [ ! -d "$HOME/.local/share/zinit" ]; then
        mkdir -p "$HOME/.local/share/zinit"
        chmod g-rw,o-rw "$HOME/.local/share/zinit"
        git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
    else
        echo "Zinit 已存在，跳过安装。"
    fi
}

# 3. 备份并创建 .zshrc
configure_zshrc() {
    echo -e "${GREEN}[3/5] 配置 .zshrc 文件...${NC}"
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%F_%T)"
        echo "旧的 .zshrc 已备份。"
    fi

    cat << 'EOF' > "$HOME/.zshrc"
# ==========================================
# Zinit 基础初始化
# ==========================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rw,o-rw "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_libs_functions} )) && _libs_functions+=( _zinit )

# ==========================================
# 加载 Powerlevel10k 主题
# ==========================================
zinit ice depth"1" # 浅克隆以加快速度
zinit light romkatv/powerlevel10k

# ==========================================
# 加载核心插件
# ==========================================

# 1. 补全增强
zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit

# 2. 语法高亮 (必须在后面加载)
zinit light zdharma-continuum/fast-syntax-highlighting

# 3. 自动建议
zinit light zsh-users/zsh-autosuggestions

# 4. 历史记录子字符串搜索
zinit light zsh-users/zsh-history-substring-search

# ==========================================
# 插件配置
# ==========================================

# zsh-history-substring-search 快捷键配置 (上下方向键)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 启用补全系统
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 加载 p10k 配置文件 (如果存在)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

# 4. 更改默认 Shell
set_default_shell() {
    echo -e "${GREEN}[4/5] 设置 Zsh 为默认 Shell...${NC}"
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s $(which zsh)
    fi
}

# 5. 完成提示
finish() {
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${GREEN}配置完成！${NC}"
    echo -e "1. 请重新连接终端或执行: ${BLUE}exec zsh${NC}"
    echo -e "2. 首次进入将启动 ${BLUE}Powerlevel10k${NC} 配置向导。"
    echo -e "3. 建议使用支持 MesloLGS NF 字体以获得最佳图标效果。"
    echo -e "${BLUE}==================================================${NC}"
}

# 执行流程
detect_os_and_install_dependencies
install_zinit
configure_zshrc
set_default_shell
finish

