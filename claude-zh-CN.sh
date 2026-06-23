#!/bin/bash
# ===================================================================
# Claude Desktop 简体中文汉化脚本 v2.6
# 适用: Claude Desktop (macOS) — 一键安装 / 卸载 / 重装
#
# 用法:
#   sudo bash claude-zh-CN.sh --install           # 一键安装（推荐）
#   sudo bash claude-zh-CN.sh --install --no-ai   # 仅汉化界面，不安装 AI 交互中文
#   sudo bash claude-zh-CN.sh --install --auto     # 安装 + 开机自动检测
#   sudo bash claude-zh-CN.sh --reinstall          # 一键重装（先卸载再安装）
#   sudo bash claude-zh-CN.sh --uninstall          # 一键卸载（全部清理）
#   sudo bash claude-zh-CN.sh --uninstall-auto     # 仅卸载自动检测
#   bash claude-zh-CN.sh --check                   # 检查汉化状态
#   bash claude-zh-CN.sh --help                    # 显示帮助
# ===================================================================

set -euo pipefail

# ── 颜色定义 ────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── 路径定义 ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_APP="/Applications/Claude.app"
JS_DIR="/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1"
RESOURCES_DIR="/Applications/Claude.app/Contents/Resources"
I18N_DIR="$RESOURCES_DIR/ion-dist/i18n"
LANG_FILE="$RESOURCES_DIR/zh-CN.json"
I18N_LANG_FILE="$I18N_DIR/zh-CN.json"
CONFIG_FILE="$HOME/Library/Application Support/Claude/config.json"
SYSTEM_PROMPT="$HOME/Library/Application Support/Claude/system_prompt.txt"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist"
INVENTORY_FILE="$HOME/.claude-zh-inventory"
VERSION="2.6"

# ── 全局变量 ────────────────────────────────────────────────────────
MODE=""
INSTALL_AI=true
INSTALL_AUTO=false
FORCE_REINSTALL=false

# ── 日志函数 ────────────────────────────────────────────────────────
log_info()  { echo -e "${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "${YELLOW}!${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_step()  { echo -e "${CYAN}→${NC} $1"; }
log_header(){ echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════${NC}"; echo -e "${BOLD}${CYAN}  $1${NC}"; echo -e "${BOLD}${CYAN}═══════════════════════════════════════════${NC}"; }

# ── 解析参数 ────────────────────────────────────────────────────────
case "${1:-}" in
    --install)
        MODE="install"
        ;;
    --reinstall)
        MODE="reinstall"
        FORCE_REINSTALL=true
        ;;
    --uninstall)
        MODE="uninstall"
        ;;
    --uninstall-auto)
        MODE="uninstall-auto"
        ;;
    --check)
        MODE="check"
        ;;
    --help|-h|help)
        MODE="help"
        ;;
    *)
        # 兼容旧参数
        for arg in "$@"; do
            case $arg in
                --no-ai|--no-ai-interaction) INSTALL_AI=false ;;
                --auto|--auto-detect) INSTALL_AUTO=true ;;
                --help|-h|help) MODE="help" ;;
                --check) MODE="check" ;;
                *) ;;
            esac
        done
        if [[ "$MODE" == "" ]]; then
            MODE="install"
        fi
        ;;
esac

# ── 帮助信息 ────────────────────────────────────────────────────────
show_help() {
    echo ""
    echo -e "${BOLD}Claude Desktop 简体中文汉化脚本 v${VERSION}${NC}"
    echo ""
    echo -e "${BOLD}用法:${NC}"
    echo "  sudo bash claude-zh-CN.sh --install           一键安装（界面汉化 + AI交互中文 + 开机自动检测）"
    echo "  sudo bash claude-zh-CN.sh --install --no-ai   仅汉化界面，不安装 AI 交互中文"
    echo "  sudo bash claude-zh-CN.sh --install --auto    安装 + 开机自动检测（默认行为）"
    echo "  sudo bash claude-zh-CN.sh --reinstall         一键重装（先卸载再安装）"
    echo "  sudo bash claude-zh-CN.sh --uninstall         一键卸载（全部清理）"
    echo "  sudo bash claude-zh-CN.sh --uninstall-auto    仅卸载开机自动检测"
    echo "  bash claude-zh-CN.sh --check                  检查汉化状态"
    echo ""
    echo -e "${BOLD}安装后功能:${NC}"
    echo "  ✓ 界面汉化 — 16,000+ 条中文字符串覆盖整个 Claude 界面"
    echo "  ✓ AI 交互中文 — Chat / Cowork / Code 模式下全程中文交流"
    echo "  ✓ 开机自动检测 — 每次开机自动修复汉化失效"
    echo ""
    echo -e "${BOLD}卸载后效果:${NC}"
    echo "  ✓ 恢复 Claude 原始英文界面"
    echo "  ✓ 清除所有汉化痕迹"
    echo ""
    echo -e "${BOLD}快速修复:${NC}"
    echo "  Claude 更新后变回英文？运行:"
    echo "  sudo bash claude-zh-CN.sh --install"
    echo ""
}

# ── 一键安装 ────────────────────────────────────────────────────────
do_install() {
    log_header "Claude Desktop 简体中文汉化 v${VERSION}"

    # 1. 检查 Claude.app
    if [[ ! -d "$CLAUDE_APP" ]]; then
        log_error "未找到 $CLAUDE_APP"
        log_info "请先安装 Claude Desktop"
        exit 1
    fi
    CLAUDE_VERSION=$(defaults read "$CLAUDE_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "未知")
    log_info "Claude 版本: $CLAUDE_VERSION"

    # 2. 退出 Claude
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

    # 3. 临时获取权限并安装
    log_step "安装翻译文件（需要 sudo 权限）..."

    # 备份原文件
    if [[ -f "$LANG_FILE" ]] && { [[ "$FORCE_REINSTALL" == true ]] || [[ ! -f "$LANG_FILE.bak" ]]; }; then
        cp "$LANG_FILE" "$LANG_FILE.bak" 2>/dev/null || true
    fi

    # 复制翻译文件（后端 + 前端）
    if [[ -f "$SCRIPT_DIR/language-pack/zh-CN.json" ]]; then
        cp "$SCRIPT_DIR/language-pack/zh-CN.json" "$LANG_FILE" 2>/dev/null && log_info "后端翻译已安装" || log_warn "后端翻译安装失败"
        cp "$SCRIPT_DIR/language-pack/zh-CN.json" "$I18N_LANG_FILE" 2>/dev/null && log_info "前端翻译已安装" || log_warn "前端翻译安装失败"
    else
        log_error "找不到翻译文件: $SCRIPT_DIR/language-pack/zh-CN.json"
        exit 1
    fi

    # 4. 应用汉化补丁
    log_step "应用汉化补丁..."
    sudo python3 "$SCRIPT_DIR/patch_js.py" 2>&1 | grep -v "^$" || log_info "汉化补丁已应用"

    # 5. 安装 system_prompt.txt（AI 交互中文）
    if [[ "$INSTALL_AI" == true ]]; then
        log_step "安装 AI 交互中文提示词..."
        mkdir -p "$HOME/Library/Application Support/Claude" 2>/dev/null || true
        cat > "$SYSTEM_PROMPT" << 'PROMPT_EOF'
# Claude AI 中文交互指令

你是一个专业的软件开发助手，你需要始终使用简体中文与用户交流。具体要求：

1. 所有回复内容必须使用简体中文，包括：
   - 代码注释
   - 错误信息解释
   - 技术分析说明
   - 命令行输出说明
   - 文件内容描述
   - 调试信息
   - 解决方案建议

2. 即使是技术术语也要在首次使用时提供中文解释

3. 代码本身保持原有的英文格式，但在关键逻辑处添加中文注释

4. 当执行命令或工具时，用中文解释执行目的和预期结果

5. 在文件操作、代码审查、系统管理等场景中，全程使用中文进行沟通

6. 当遇到多语言混杂的情况，主动转换为简体中文表达

7. 保持专业但友好的语气，用中文自然流畅地交流

8. 这个指令适用于所有交互模式：chat 模式、cowork 模式、code 模式等

9. 在 AI 内部思考过程（thinking/reasoning）中也使用中文

10. 确保所有技术文档、错误堆栈分析、解决方案说明都用中文呈现
PROMPT_EOF
        log_info "AI 交互中文已启用"
    fi

    # 6. 安装开机自动检测
    if [[ "$INSTALL_AUTO" == true || "$INSTALL_AUTO" == false ]]; then
        # 默认安装自动检测（用户可以用 --uninstall-auto 单独卸载）
        install_auto_launch
    fi

    # 7. 创建安装清单
    create_inventory

    log_header "✓ 安装完成！"
    log_info "界面汉化已启用"
    if [[ "$INSTALL_AI" == true ]]; then
        log_info "AI 交互中文已启用"
    fi
    if [[ "$INSTALL_AUTO" == true ]]; then
        log_info "开机自动检测已启用"
    fi
    echo ""
    log_info "重新打开 Claude，界面将显示为简体中文"
    if [[ "$INSTALL_AI" == true ]]; then
        log_info "Claude AI 将全程使用中文与你交流"
    fi
    echo ""
    log_info "下次 Claude 更新后若变回英文，运行:"
    log_info "  sudo bash claude-zh-CN.sh --reinstall"
}

# ── 安装开机自动检测 ───────────────────────────────────────────────
install_auto_launch() {
    local auto_script="$SCRIPT_DIR/claude-zh-autolaunch.sh"
    local fixed_script="$HOME/Library/Application Support/Claude/autolaunch.sh"

    # 创建修复后的 autolaunch 脚本（避免依赖 sudo）
    cat > "$fixed_script" << 'FIXED_EOF'
#!/bin/bash
# Claude Desktop 开机自动汉化脚本（修复版）
# 由 com.claude-zh-CN.auto-launch.plist 调用
# 此脚本在用户权限下运行，不使用 sudo

sleep 30  # 等待 30 秒，确保系统就绪

PATCH_SCRIPT="/Users/xiaota/WorkBuddy/Claude-Chinese-Toolkit/patch_js.py"
AUTO_SCRIPT="/Users/xiaota/WorkBuddy/Claude-Chinese-Toolkit/claude-zh-autolaunch.sh"

# 优先使用项目目录下的脚本，否则使用用户目录下的
if [[ -f "$PATCH_SCRIPT" ]]; then
    CHECK_OUTPUT=$("$PATCH_SCRIPT" --check 2>&1)
elif [[ -f "$AUTO_SCRIPT" ]]; then
    CHECK_OUTPUT=$("$AUTO_SCRIPT" --check 2>&1)
else
    echo "[$(date)] 补丁脚本不存在，跳过自动检测" >> /tmp/claude-zh-autolaunch.log
    exit 0
fi

if echo "$CHECK_OUTPUT" | grep -q "需要重新汉化"; then
    echo "[$(date)] 检测到汉化失效，正在修复..." >> /tmp/claude-zh-autolaunch.log
    "$PATCH_SCRIPT" 2>/dev/null && echo "[$(date)] 汉化修复成功" >> /tmp/claude-zh-autolaunch.log || echo "[$(date)] 汉化修复失败" >> /tmp/claude-zh-autolaunch.log
else
    echo "[$(date)] 汉化状态正常，无需修复" >> /tmp/claude-zh-autolaunch.log
fi
FIXED_EOF
    chmod +x "$fixed_script"

    # 创建 LaunchAgent plist
    cat > "$LAUNCH_AGENT_PLIST" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude-zh-CN.auto-launch</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>sleep 30 && /Users/xiaota/Library/Application\ Support/Claude/autolaunch.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/claude-zh-autolaunch.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/claude-zh-autolaunch-error.log</string>
</dict>
</plist>
PLIST_EOF

    # 尝试加载 LaunchAgent
    launchctl bootstrap gui/$(id -u) "$LAUNCH_AGENT_PLIST" 2>/dev/null || \
    launchctl load "$LAUNCH_AGENT_PLIST" 2>/dev/null || \
    log_warn "LaunchAgent 加载失败（可忽略，下次开机将自动生效）"

    log_info "开机自动检测已启用"
    log_info "  日志位置: /tmp/claude-zh-autolaunch.log"
}

# ── 创建安装清单 ───────────────────────────────────────────────────
create_inventory() {
    cat > "$INVENTORY_FILE" << INVENTORY_EOF
# Claude-Chinese-Toolkit 安装清单
# 创建于 $(date '+%Y-%m-%d %H:%M:%S')

FILES=/Applications/Claude.app/Contents/Resources/zh-CN.json
FILES=/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json
FILES=$SYSTEM_PROMPT
FILES=$LAUNCH_AGENT_PLIST
FILES=$HOME/Library/Application Support/Claude/autolaunch.sh
CONFIG=config.json (locale 设置为 zh-CN)
INVENTORY_EOF
    log_info "已创建安装清单: $INVENTORY_FILE"
}

# ── 一键卸载 ────────────────────────────────────────────────────────
do_uninstall() {
    log_header "开始卸载 Claude 汉化"

    # 1. 停止并卸载 LaunchAgent
    if [[ -f "$LAUNCH_AGENT_PLIST" ]]; then
        log_step "移除开机自动检测..."
        launchctl bootout gui/$(id -u) "$LAUNCH_AGENT_PLIST" 2>/dev/null || \
        launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
        rm -f "$LAUNCH_AGENT_PLIST"
        log_info "开机自动检测已移除"
    fi

    # 2. 恢复翻译文件（如果有备份）
    log_step "恢复翻译文件..."
    if [[ -f "$LANG_FILE.bak" ]]; then
        mv "$LANG_FILE.bak" "$LANG_FILE" 2>/dev/null && log_info "后端翻译已恢复" || log_warn "恢复失败"
    else
        # 没有备份，直接恢复为空文件（或者保留英文版）
        if [[ -f "$RESOURCES_DIR/en-US.json" ]]; then
            cp "$RESOURCES_DIR/en-US.json" "$LANG_FILE" 2>/dev/null && log_info "已恢复为英文版" || log_warn "恢复失败"
        else
            log_warn "未找到备份，已删除汉化文件"
            rm -f "$LANG_FILE"
        fi
    fi

    if [[ -f "$I18N_LANG_FILE" ]]; then
        if [[ -f "$I18N_DIR/en-US.json" ]]; then
            cp "$I18N_DIR/en-US.json" "$I18N_LANG_FILE" 2>/dev/null || true
        else
            rm -f "$I18N_LANG_FILE"
        fi
    fi

    # 3. 恢复 JS 文件（如果有备份）
    log_step "恢复 JS 文件..."
    for js_file in "$JS_DIR"/index-*.js; do
        if [[ -f "$js_file.bak" ]]; then
            mv "$js_file.bak" "$js_file" 2>/dev/null && log_info "已恢复 $js_file" || log_warn "恢复失败"
        fi
    done

    # 4. 移除 system_prompt.txt
    if [[ -f "$SYSTEM_PROMPT" ]]; then
        log_step "移除 AI 交互中文..."
        rm -f "$SYSTEM_PROMPT"
        log_info "已移除"
    fi

    # 5. 移除其他文件
    rm -f "$HOME/Library/Application Support/Claude/autolaunch.sh"
    rm -f "$INVENTORY_FILE"

    # 6. 恢复 config.json 中的 locale
    if [[ -f "$CONFIG_FILE" ]]; then
        local tmp_config="${CONFIG_FILE}.tmp"
        if python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    if 'locale' in config:
        del config['locale']
    with open('$tmp_config', 'w') as f:
        json.dump(config, f, indent=2)
    print('yes')
except:
    print('no')
" 2>/dev/null; then
            mv "$tmp_config" "$CONFIG_FILE" 2>/dev/null || true
        fi
    fi

    log_header "✓ 卸载完成！"
    log_info "所有汉化痕迹已清理"
    log_info "重新打开 Claude，界面将恢复为英文"
}

# ── 一键重装 ────────────────────────────────────────────────────────
do_reinstall() {
    log_warn "即将重装 Claude 汉化，当前设置将被清除..."
    log_step "请稍候..."

    # 先卸载
    do_uninstall

    # 短暂等待
    sleep 1

    # 再安装（但不卸载自动检测功能）
    INSTALL_AUTO=true
    do_install
}

# ── 仅卸载自动检测 ─────────────────────────────────────────────────
do_uninstall_auto() {
    log_header "移除开机自动检测"

    if [[ -f "$LAUNCH_AGENT_PLIST" ]]; then
        launchctl bootout gui/$(id -u) "$LAUNCH_AGENT_PLIST" 2>/dev/null || \
        launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
        rm -f "$LAUNCH_AGENT_PLIST"
        log_info "开机自动检测已移除"
    else
        log_info "未发现自动检测配置"
    fi
}

# ── 检查汉化状态 ───────────────────────────────────────────────────
do_check() {
    log_header "汉化状态检测"

    # 1. 检查汉化补丁
    python3 "$SCRIPT_DIR/patch_js.py" --check 2>&1

    # 2. 检查翻译文件
    echo ""
    if [[ -f "$LANG_FILE" ]]; then
        local size=$(stat -f%z "$LANG_FILE" 2>/dev/null || echo "未知")
        log_info "后端翻译: zh-CN.json (${size} bytes)"
    else
        log_warn "后端翻译: 不存在"
    fi

    if [[ -f "$I18N_LANG_FILE" ]]; then
        local size=$(stat -f%z "$I18N_LANG_FILE" 2>/dev/null || echo "未知")
        log_info "前端翻译: ion-dist/i18n/zh-CN.json (${size} bytes)"
    else
        log_warn "前端翻译: 不存在"
    fi

    # 3. 检查 AI 交互中文
    echo ""
    if [[ -f "$SYSTEM_PROMPT" ]]; then
        log_info "AI 交互中文: 已启用"
    else
        log_warn "AI 交互中文: 未启用"
    fi

    # 4. 检查 LaunchAgent
    echo ""
    if [[ -f "$LAUNCH_AGENT_PLIST" ]]; then
        log_info "开机自动检测: 配置已存在"
    else
        log_warn "开机自动检测: 未配置"
    fi

    echo ""
}

# ── 主流程 ──────────────────────────────────────────────────────────
case "$MODE" in
    install)
        do_install
        ;;
    reinstall)
        do_reinstall
        ;;
    uninstall)
        do_uninstall
        ;;
    uninstall-auto)
        do_uninstall_auto
        ;;
    check)
        do_check
        ;;
    help)
        show_help
        ;;
    *)
        log_error "未知模式: $MODE"
        show_help
        exit 1
        ;;
esac
