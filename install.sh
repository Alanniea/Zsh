#!/bin/bash

# --- 颜色定义 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}开始配置 Zsh 环境...${NC}"

# 1. 安装基础依赖
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

# 3. 生成 .zshrc
echo -e "${GREEN}正在生成 .zshrc 配置...${NC}"
cat << 'EOF' > ~/.zshrc
# Zinit 基础
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# 插件加载
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# 快捷键与初始化
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
autoload -Uz compinit && compinit
zinit cdreplay -q
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# --- 4. 自动化切换默认 Shell 逻辑 ---
CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(command -v zsh)

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo -e "${BLUE}检测到当前 Shell 是 $CURRENT_SHELL，准备切换到 Zsh...${NC}"
    
    # 尝试切换。注意：这里会触发密码验证
    if sudo chsh -s "$ZSH_PATH" "$USER"; then
        echo -e "${GREEN}成功！默认 Shell 已修改为 Zsh。${NC}"
        echo -e "${BLUE}提示：配置将在下次登录或重新连接 SSH 时生效。${NC}"
    else
        echo -e "${RED}自动切换失败，可能需要手动执行: chsh -s $ZSH_PATH${NC}"
    fi
else
    echo -e "${GREEN}当前已经是 Zsh 环境，无需切换。${NC}"
fi

echo -e "\n${BLUE}安装完成！请重新启动终端。${NC}"
