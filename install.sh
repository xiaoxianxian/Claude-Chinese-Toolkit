#!/bin/bash
# ===================================================================
# Claude Desktop 简体中文汉化 — 一键安装器 (curl pipe)
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/xiaoxianxian/Claude-Chinese-Toolkit/main/install.sh | bash
#
# 或者下载到本地执行:
#   curl -fsSL -o install.sh https://raw.githubusercontent.com/xiaoxianxian/Claude-Chinese-Toolkit/main/install.sh
#   chmod +x install.sh
#   sudo ./install.sh
# ===================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "${YELLOW}!${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_step()  { echo -e "${CYAN}→${NC} $1"; }
log_header(){ echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════${NC}"; echo -e "${BOLD}${CYAN}  $1${NC}"; echo -e "${BOLD}${CYAN}═══════════════════════════════════════════${NC}"; }

echo ""
echo -e "${BOLD}${CYAN}Claude Desktop 简体中文汉化 v2.6 — 一键安装器${NC}"
echo ""

# 检查 Claude.app
if [[ ! -d "/Applications/Claude.app" ]]; then
    log_error "未找到 /Applications/Claude.app"
    log_info "请先安装 Claude Desktop: https://claude.ai/download"
    exit 1
fi

CLAUDE_VERSION=$(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "未知")
log_info "Claude 版本: $CLAUDE_VERSION"

# 退出 Claude
if pgrep -x "Claude" > /dev/null 2>&1; then
    log_step "正在退出 Claude..."
    killall Claude 2>/dev/null || true
    for i in {1..10}; do
        pgrep -x "Claude" > /dev/null 2>&1 || break
        sleep 1
    done
    if pgrep -x "Claude" > /dev/null 2>&1; then
        log_error "无法退出 Claude，请手动 Cmd+Q 后重试"
        exit 1
    fi
fi
log_info "Claude 已退出"

# 调用主脚本进行安装
log_step "开始安装汉化..."
exec bash "$SCRIPT_DIR/claude-zh-CN.sh" --install
