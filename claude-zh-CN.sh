#!/bin/bash

# ===================================================================
# Claude Desktop 简体中文汉化脚本 v2.3
# 适用: Claude Desktop (macOS) — 自动检测版本
# 用法: bash claude-zh-CN.sh [--check]
# ===================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "$1"; }

# ── 检查 Claude.app ───────────────────────────────────────────────
if [[ ! -d "/Applications/Claude.app" ]]; then
    log "${RED}✗ 未找到 /Applications/Claude.app${NC}"
    log "  请先安装 Claude Desktop"
    exit 1
fi

# ── --check 模式 ───────────────────────────────────────────────────
if [[ "${1:-}" == "--check" ]]; then
    python3 "$SCRIPT_DIR/patch_js.py" --check
    exit $?
fi

# ── 显示版本信息 ───────────────────────────────────────────────────
log "${CYAN}Claude-Chinese-Toolkit v2.3${NC}"
log "Claude 版本: $(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo '未知')"
log ""

# ── 退出 Claude ─────────────────────────────────────────────────────
if pgrep -x "Claude" > /dev/null 2>&1; then
    log "${YELLOW}→ Claude 正在运行，正在退出...${NC}"
    killall Claude 2>/dev/null || true
    for i in {1..10}; do
        pgrep -x "Claude" > /dev/null 2>&1 || break
        sleep 1
    done
    if pgrep -x "Claude" > /dev/null 2>&1; then
        log "${RED}✗ 无法退出 Claude，请手动 Cmd+Q 关闭后重试${NC}"
        exit 1
    fi
fi
log "${GREEN}✓ Claude 已退出${NC}"

# ── 运行 Python 补丁脚本 ───────────────────────────────────────
log ""
log "${CYAN}→ 需要 sudo 权限来修改 Claude.app 文件...${NC}"
log ""

sudo python3 "$SCRIPT_DIR/patch_js.py"
EXIT_CODE=$?

# ── 如果 sudo 被跳过，尝试直接运行（可能已解锁）────────────
if [[ $EXIT_CODE -ne 0 ]]; then
    log ""
    log "${YELLOW}→ sudo 失败，尝试直接运行...${NC}"
    python3 "$SCRIPT_DIR/patch_js.py"
fi
