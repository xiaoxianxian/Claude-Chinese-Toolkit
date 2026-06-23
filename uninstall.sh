#!/bin/bash
# ===================================================================
# Claude Desktop 简体中文汉化 — 一键卸载器
#
# 用法:
#   sudo bash uninstall.sh           # 一键卸载全部
#   bash uninstall.sh --check-only   # 仅检查，不删除
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

ACTION="uninstall"
CHECK_ONLY=false

# 解析参数
for arg in "$@"; do
    case $arg in
        --check-only|-n)
            CHECK_ONLY=true
            ;;
        *)
            ;;
    esac
done

echo ""
echo -e "${BOLD}${CYAN}Claude Desktop 汉化 — 一键卸载${NC}"
echo ""

# 定义要清理的文件和目录
FILES_TO_REMOVE=(
    "/Applications/Claude.app/Contents/Resources/zh-CN.json"
    "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json"
    "$HOME/Library/Application Support/Claude/system_prompt.txt"
    "$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist"
    "$HOME/Library/Application Support/Claude/autolaunch.sh"
    "$HOME/.claude-zh-inventory"
)

BACKUP_FILES=(
    "/Applications/Claude.app/Contents/Resources/zh-CN.json.bak"
)

if [[ "$CHECK_ONLY" == true ]]; then
    log_header "检查汉化安装痕迹"
    echo ""
    for f in "${FILES_TO_REMOVE[@]}"; do
        if [[ -f "$f" ]]; then
            log_info "存在: $f"
        else
            log_warn "不存在: $f"
        fi
    done
    exit 0
fi

log_step "开始清理..."

# 1. 停止并卸载 LaunchAgent
if [[ -f "$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist" ]]; then
    log_step "移除开机自动检测..."
    launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist" 2>/dev/null || \
    launchctl unload "$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist" 2>/dev/null || true
    rm -f "$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist"
    log_info "开机自动检测已移除"
fi

# 2. 恢复翻译文件
log_step "恢复翻译文件..."
if [[ -f "/Applications/Claude.app/Contents/Resources/zh-CN.json.bak" ]]; then
    mv "/Applications/Claude.app/Contents/Resources/zh-CN.json.bak" "/Applications/Claude.app/Contents/Resources/zh-CN.json" 2>/dev/null && log_info "后端翻译已恢复" || log_warn "恢复失败"
else
    if [[ -f "/Applications/Claude.app/Contents/Resources/en-US.json" ]]; then
        cp "/Applications/Claude.app/Contents/Resources/en-US.json" "/Applications/Claude.app/Contents/Resources/zh-CN.json" 2>/dev/null && log_info "已恢复为英文版"
    else
        rm -f "/Applications/Claude.app/Contents/Resources/zh-CN.json" 2>/dev/null && log_info "已删除汉化文件"
    fi
fi

if [[ -f "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json" ]]; then
    if [[ -f "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json" ]]; then
        cp "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json" "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json" 2>/dev/null || true
    else
        rm -f "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json" 2>/dev/null
    fi
fi

# 3. 恢复 JS 文件
log_step "恢复 JS 文件..."
for js_file in /Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/index-*.js; do
    if [[ -f "${js_file}.bak" ]]; then
        mv "${js_file}.bak" "$js_file" 2>/dev/null && log_info "已恢复 $(basename $js_file)" || log_warn "恢复失败"
    fi
done

# 4. 移除 system_prompt.txt
if [[ -f "$HOME/Library/Application Support/Claude/system_prompt.txt" ]]; then
    log_step "移除 AI 交互中文..."
    rm -f "$HOME/Library/Application Support/Claude/system_prompt.txt"
    log_info "已移除"
fi

# 5. 移除其他文件
rm -f "$HOME/Library/Application Support/Claude/autolaunch.sh"
rm -f "$HOME/.claude-zh-inventory"

# 6. 恢复 config.json
if [[ -f "$HOME/Library/Application Support/Claude/config.json" ]]; then
    CONFIG_FILE="$HOME/Library/Application Support/Claude/config.json"
    TMP_FILE="${CONFIG_FILE}.tmp.$$"
    if python3 -c "
import json, sys
try:
    with open(sys.argv[1], 'r') as f:
        config = json.load(f)
    if 'locale' in config:
        del config['locale']
    with open(sys.argv[2], 'w') as f:
        json.dump(config, f, indent=2)
    print('ok')
except Exception as e:
    print(f'error: {e}')
" "$CONFIG_FILE" "$TMP_FILE" 2>/dev/null | grep -q "ok"; then
        mv "$TMP_FILE" "$CONFIG_FILE" 2>/dev/null || rm -f "$TMP_FILE"
    else
        rm -f "$TMP_FILE" 2>/dev/null || true
    fi
fi

log_header "✓ 卸载完成！"
log_info "所有汉化痕迹已清理"
log_info "重新打开 Claude，界面将恢复为英文"
log_info "AI 交互也将恢复为默认语言"
