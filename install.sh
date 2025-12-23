#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}开始配置 Zsh 环境...${NC}"

# 1. 安装基础依赖 (以 Ubuntu/Debian 为例，可根据需要调整)
if ! command -v zsh &> /dev/null; then
    echo -e "${GREEN}正在安装 Zsh...${NC}"
    sudo apt update && sudo apt install -y zsh curl git
fi

# 2. 安装 Zinit
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo -e "${GREEN}正在安装 Zinit...${NC}"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 3. 创建 .zshrc 配置文件
echo -e "${GREEN}正在生成 .zshrc...${NC}"
cat << 'EOF' > ~/.zshrc
# --- Zinit 基础配置 ---
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# 加载 Powerlevel10k 主题
zinit ice depth=1; zinit light romkatv/powerlevel10k

# --- 加载插件 ---
# 自动补全
zinit light zsh-users/zsh-completions
# 语法高亮 (fast-syntax-highlighting 比原版更快)
zinit light zdharma-continuum/fast-syntax-highlighting
# 自动建议
zinit light zsh-users/zsh-autosuggestions
# 历史记录子串搜索
zinit light zsh-users/zsh-history-substring-search

# --- 插件配置 ---
# 历史记录搜索快捷键 (上下方向键)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 启用自动补全系统
autoload -Uz compinit && compinit
zinit cdreplay -q

# 加载 P10K 配置 (如果存在)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo -e "${BLUE}配置完成！${NC}"
echo -e "1. 请执行 ${GREEN}chsh -s $(command -v zsh)${NC} 切换默认 Shell。"
echo -e "2. 重新打开终端，Powerlevel10k 将引导您进行视觉配置。"
