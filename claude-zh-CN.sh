#!/bin/bash

# ============================================================
# Claude Desktop 简体中文汉化脚本 v2.0
# 适用: Claude Desktop v1.12603.1+ (macOS)
# 用法: bash claude-zh-CN.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="/Applications/Claude.app"
RESOURCES_PATH="${APP_PATH}/Contents/Resources"
CONFIG_DIR="$HOME/Library/Application Support/Claude"
BACKUP_DIR="${SCRIPT_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }
log_header(){ echo -e "\n${CYAN}────────────────────────────────────────\n  $1\n${CYAN}────────────────────────────────────────\n"; }

check_app() {
    if [[ ! -d "$APP_PATH" ]]; then
        log_error "未找到 Claude.app ($APP_PATH)"
        exit 1
    fi
    log_info "Claude.app 已找到"
}

stop_claude() {
    if pgrep -x "Claude" > /dev/null 2>&1; then
        log_warn "Claude 正在运行，正在退出..."
        killall Claude 2>/dev/null || true
        for i in {1..10}; do
            pgrep -x "Claude" > /dev/null 2>&1 || return 0
            sleep 1
        done
        killall -9 Claude 2>/dev/null || true
        sleep 2
    fi
    log_info "Claude 未在运行"
}

check_translations() {
    local ft="${SCRIPT_DIR}/language-pack/zh-CN.json"
    local bt="${SCRIPT_DIR}/language-pack/desktop-shell-zh-CN.json"
    [[ -f "$ft" ]] || { log_error "前端翻译缺失: $ft"; exit 1; }
    [[ -f "$bt" ]] || { log_error "后端翻译缺失: $bt"; exit 1; }
    log_info "翻译文件就绪"
}

backup_files() {
    log_header "步骤 1/4: 创建备份"
    mkdir -p "$BACKUP_DIR"
    
    local js_file="${RESOURCES_PATH}/ion-dist/assets/v1/index-BQutSDqp.js"
    [[ -f "$js_file" ]] && cp "$js_file" "${BACKUP_DIR}/index-BQutSDqp.js.${TIMESTAMP}.js"
    [[ -f "${RESOURCES_PATH}/en-US.json" ]] && cp "${RESOURCES_PATH}/en-US.json" "${BACKUP_DIR}/en-US.json.${TIMESTAMP}"
    [[ -f "${CONFIG_DIR}/config.json" ]] && cp "${CONFIG_DIR}/config.json" "${BACKUP_DIR}/config.json.${TIMESTAMP}"
    
    log_info "备份: ${BACKUP_DIR}/"
}

apply_translations() {
    log_header "步骤 2/4: 安装翻译文件"
    cp "${SCRIPT_DIR}/language-pack/desktop-shell-zh-CN.json" "${RESOURCES_PATH}/zh-CN.json"
    cp "${SCRIPT_DIR}/language-pack/zh-CN.json" "${RESOURCES_PATH}/ion-dist/i18n/zh-CN.json"
    log_info "翻译文件已安装"
}

apply_js_patches() {
    log_header "步骤 3/4: 修改前端 JS"
    
    local js_file="${RESOURCES_PATH}/ion-dist/assets/v1/index-BQutSDqp.js"
    
    # 移除保护
    xattr -c "$js_file" 2>/dev/null || true
    chflags nouchg "$js_file" 2>/dev/null || true
    
    # 用 Python 打补丁
    python3 << 'PYEOF'
import sys, os

js_path = "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/index-BQutSDqp.js"

with open(js_path, 'r') as f:
    content = f.read()

patches = [
    ('const wEt="spa:locale",kEt=NS([(()=>{try{return localStorage.getItem(wEt)}catch{return null}})(),...navigator.languages])',
     'const wEt="spa:locale",kEt="zh-CN"'),
    ('const n=NS([s.locale])',
     'const n=NS([s.locale=="en-US"?"zh-CN":s.locale])'),
]

results = []
for old, new in patches:
    if old in content:
        content = content.replace(old, new)
        results.append(f"  ✓ 补丁应用成功")
    else:
        results.append(f"  ! 跳过: 已打过补丁或版本不匹配")

with open(js_path, 'w') as f:
    f.write(content)

for r in results:
    print(r)
PYEOF
    
    log_info "JS 补丁完成"
}

patch_config() {
    log_header "步骤 4/4: 修改配置文件"
    
    local config_file="${CONFIG_DIR}/config.json"
    [[ -f "$config_file" ]] || { log_error "config.json 不存在"; exit 1; }
    
    python3 << PYEOF
import os
config_path = os.path.expanduser("~") + "/Library/Application Support/Claude/config.json"
try:
    with open(config_path, 'r') as f:
        c = f.read()
    if '"locale": "en-US"' in c:
        c = c.replace('"locale": "en-US"', '"locale": "zh-CN"')
        with open(config_path, 'w') as f:
            f.write(c)
        print("  ✓ config.json locale → zh-CN")
    else:
        print("  ! config.json 已为 zh-CN 或无 locale 字段")
except PermissionError:
    print("  ✗ 权限不足，请手动修改:")
    print(f"    文件: {config_path}")
    print("    将 \"locale\": \"en-US\" 改为 \"locale\": \"zh-CN\"")
PYEOF
}

finish() {
    log_header "汉化完成！"
    
    echo -e "${GREEN}补丁已应用:${NC}"
    echo "  ✓ 后端翻译 (Resources/zh-CN.json)"
    echo "  ✓ 前端翻译 (ion-dist/i18n/zh-CN.json)"  
    echo "  ✓ kEt 硬编码为 zh-CN"
    echo "  ✓ jEt locale 强制覆盖 en-US → zh-CN"
    echo "  ✓ config.json locale → zh-CN"
    
    echo -e "\n${GREEN}下一步:${NC}"
    echo "  1. 完全退出 Claude (Cmd + Q)"
    echo "  2. 重新打开 Claude"
    echo ""
    echo -e "${CYAN}备份: ${BACKUP_DIR}/${NC}"
    echo ""
}

# 主流程
check_app
stop_claude
check_translations
backup_files
apply_translations
apply_js_patches
patch_config
finish
