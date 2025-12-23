#!/bin/bash

# --- 颜色定义 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}开始全自动配置 Zsh 环境...${NC}"

# 1. 安装基础依赖
if ! command -v zsh &> /dev/null; then
    echo -e "${GREEN}正在安装 Zsh 及必要工具...${NC}"
    # 针对 Debian/Ubuntu 系统，如果是其他系统请手动调整安装命令
    sudo apt update && sudo apt install -y zsh curl git
fi

# 2. 安装 Zinit 插件管理器
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo -e "${GREEN}正在安装 Zinit...${NC}"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 3. 创建并配置 .zshrc (包含历史记录修复)
echo -e "${GREEN}正在配置 .zshrc 并启用历史记录...${NC}"

cat << 'EOF' > ~/.zshrc
# --- 1. 历史记录配置 (修复无 ~/.zsh_history 问题) ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# 历史记录优化选项
setopt share_history          # 会话间共享历史
setopt append_history         # 追加写入
setopt inc_append_history     # 立即写入
setopt hist_ignore_all_dups   # 忽略重复
setopt hist_ignore_space      # 忽略空格开头的命令

# --- 2. Zinit 基础配置 ---
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# 加载 Powerlevel10k 主题
zinit ice depth=1; zinit light romkatv/powerlevel10k

# --- 3. 插件加载 ---
# 自动补全
zinit light zsh-users/zsh-completions
# 语法高亮
zinit light zdharma-continuum/fast-syntax-highlighting
# 自动建议
zinit light zsh-users/zsh-autosuggestions
# 历史记录子串搜索
zinit light zsh-users/zsh-history-substring-search

# --- 4. 插件个性化配置 ---
# 绑定上下方向键用于历史子串搜索
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 启用补全系统
autoload -Uz compinit && compinit
zinit cdreplay -q

# 加载 P10K 视觉配置 (如果存在)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# 4. 预创建历史文件并设置权限
touch ~/.zsh_history
chmod 600 ~/.zsh_history

# --- 5. 自动切换默认 Shell ---
ZSH_PATH=$(command -v zsh)
CURRENT_SHELL_NAME=$(basename "$SHELL")

if [ "$CURRENT_SHELL_NAME" != "zsh" ]; then
    echo -e "${BLUE}准备将默认 Shell 切换为 Zsh...${NC}"
    # 调用 chsh，这通常需要输入当前用户密码
    if sudo chsh -s "$ZSH_PATH" "$USER"; then
        echo -e "${GREEN}默认 Shell 切换成功！${NC}"
    else
        echo -e "${RED}自动切换失败，请稍后手动运行: chsh -s $ZSH_PATH${NC}"
    fi
else
    echo -e "${GREEN}已经是 Zsh 环境。${NC}"
fi

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}所有配置已完成！${NC}"
echo -e "${BLUE}1. 请【关闭当前终端】并【重新打开】以激活配置。${NC}"
echo -e "${BLUE}2. 首次进入会触发 Powerlevel10k 配置向导，按提示操作即可。${NC}"
echo -e "${BLUE}3. 如果图标显示异常，请确保终端已安装并使用 Nerd Fonts。${NC}"
echo -e "${BLUE}==================================================${NC}"
