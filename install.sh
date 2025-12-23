#!/bin/bash

# --- 颜色定义 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}开始配置 Zsh 环境 (包含历史记录优化)...${NC}"

# 1. 安装基础依赖
if ! command -v zsh &> /dev/null; then
    echo -e "${GREEN}正在安装 Zsh...${NC}"
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y zsh curl git
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y zsh curl git
    else
        echo -e "${RED}未识别的操作系统，请手动安装 zsh, curl, git${NC}"
    fi
fi

# 2. 安装 Zinit 插件管理器
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo -e "${GREEN}正在安装 Zinit...${NC}"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 3. 强制创建历史记录文件并设置权限
if [ ! -f "$HOME/.zsh_history" ]; then
    echo -e "${GREEN}正在初始化历史记录文件...${NC}"
    touch "$HOME/.zsh_history"
    chmod 600 "$HOME/.zsh_history"
fi

# 4. 生成完整的 .zshrc
echo -e "${GREEN}正在生成 .zshrc 配置...${NC}"
cat << 'EOF' > ~/.zshrc
# --- 历史记录配置 (修复缺失问题) ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# 历史记录行为优化
setopt share_history          # 会话间共享历史
setopt append_history         # 追加模式
setopt inc_append_history     # 立即写入
setopt hist_ignore_all_dups   # 删除重复
setopt hist_ignore_space      # 忽略空格开头的命令
setopt hist_reduce_blanks     # 去除多余空格

# --- Zinit 基础配置 ---
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# 加载主题 (Powerlevel10k)
zinit ice depth=1; zinit light romkatv/powerlevel10k

# 加载功能插件
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# --- 插件行为设置 ---
# 绑定上下方向键用于历史子串搜索
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 自动补全初始化
autoload -Uz compinit && compinit
zinit cdreplay -q

# 加载 P10K 视觉配置 (如果存在)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# 5. 自动化切换默认 Shell
CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(command -v zsh)

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo -e "${BLUE}检测到当前 Shell 是 $CURRENT_SHELL，准备切换到 Zsh...${NC}"
    echo -e "${RED}请输入用户密码以更改默认 Shell:${NC}"
    
    if sudo chsh -s "$ZSH_PATH" "$USER"; then
        echo -e "${GREEN}成功！默认 Shell 已修改为 $ZSH_PATH${NC}"
    else
        echo -e "${RED}自动切换失败，请稍后手动执行: chsh -s $ZSH_PATH${NC}"
    fi
else
    echo -e "${GREEN}当前已经是 Zsh 环境。${NC}"
fi

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}配置完成！${NC}"
echo -e "${BLUE}1. 请重新连接 SSH 或重启终端以生效。${NC}"
echo -e "${BLUE}2. 首次进入 Zsh 将自动运行 Powerlevel10k 样式配置向导。${NC}"
echo -e "${BLUE}3. 历史记录文件已确认: $HOME/.zsh_history${NC}"
echo -e "${BLUE}==================================================${NC}"
