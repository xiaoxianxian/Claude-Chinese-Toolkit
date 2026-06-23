#!/bin/bash

# ===================================================================
# Claude Desktop 简体中文汉化脚本 v2.5
# 适用: Claude Desktop (macOS) — 自动检测版本 + 开机自动汉化
# 用法: bash claude-zh-CN.sh [--check] [--no-system] [--uninstall-auto]
#       --no-system: 跳过安装系统提示词（仅汉化界面）
#       --uninstall-auto: 移除开机自动汉化（不删除汉化）
# ===================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "$1"; }
SKIP_SYSTEM_PROMPT=false
UNINSTALL_AUTO_LAUNCH=false

# ── 解析参数 ──────────────────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --no-system)
            SKIP_SYSTEM_PROMPT=true
            shift
            ;;
        --uninstall-auto)
            UNINSTALL_AUTO_LAUNCH=true
            shift
            ;;
        --check)
            PYTHON_ARGS="--check"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# ── 检查 Claude.app ───────────────────────────────────────────────
if [[ ! -d "/Applications/Claude.app" ]]; then
    log "${RED}✗ 未找到 /Applications/Claude.app${NC}"
    log "  请先安装 Claude Desktop"
    exit 1
fi

# ── --check 模式 ───────────────────────────────────────────────────
if [[ ! -z "${PYTHON_ARGS:-}" ]]; then
    python3 "$SCRIPT_DIR/patch_js.py" --check
    exit $?
fi

# ── 显示版本信息 ───────────────────────────────────────────────────
log "${CYAN}Claude-Chinese-Toolkit v2.5${NC}"
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

# ── 确认安装系统提示词 ───────────────────────────────────────────
SYSTEM_PROMPT_CONFIG="$HOME/Library/Application Support/Claude/system_prompt.txt"
SYSTEM_PROMPT_CONTENT="# Claude AI 中文交互指令

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
   
8. 这个指令适用于所有交互模式：chat模式、cowork模式、code模式等
   
9. 在AI内部思考过程（thinking/reasoning）中也使用中文
   
10. 确保所有技术文档、错误堆栈分析、解决方案说明都用中文呈现"

if [[ "$SKIP_SYSTEM_PROMPT" == false && ! -f "$SYSTEM_PROMPT_CONFIG" ]]; then
    log ""
    log "${CYAN}🤖 AI 交互语言设置${NC}"
    log "${GREEN}是否安装系统提示词，让 Claude AI 全程使用中文与你交流？${NC}"
    log ""
    log "  这将启用：Chat / Cowork / Code 模式下的中文交互"
    log "  提示词将保存在: $SYSTEM_PROMPT_CONFIG"
    log ""
    log "  选项:"
    log "    1) 安装系统提示词 + 汉化界面 + 开机自动汉化（推荐）"
    log "    2) 仅汉化界面，跳过系统提示词（跳过开机自动汉化）"
    log "    3) 仅汉化界面 + 开机自动汉化，跳过系统提示词"
    log "    4) 退出"
    log ""
    read -p "请输入选择 [1/2/3/4]: " -n 1 -r
    log ""
    
    case $REPLY in
        2)
            SKIP_SYSTEM_PROMPT=true
            ;;
        3)
            SKIP_SYSTEM_PROMPT=true
            ;;
        4)
            log "${YELLOW}已取消操作${NC}"
            exit 0
            ;;
        *)
            SKIP_SYSTEM_PROMPT=false
            ;;
    esac
fi

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

# ── 安装系统提示词 ─────────────────────────────────────────────
if [[ "$SKIP_SYSTEM_PROMPT" == false ]]; then
    log ""
    log "${CYAN}── 步骤 4/4: 安装 AI 交互中文提示词 ─────────────"
    
    PROMPT_DIR="$(dirname "$SYSTEM_PROMPT_CONFIG")"
    mkdir -p "$PROMPT_DIR" 2>/dev/null || true
    
    if echo "$SYSTEM_PROMPT_CONTENT" > "$SYSTEM_PROMPT_CONFIG" 2>/dev/null; then
        log "${GREEN}✓ 系统提示词已安装 → system_prompt.txt${NC}"
        log "  位置: $SYSTEM_PROMPT_CONFIG"
    elif [[ -f "$SYSTEM_PROMPT_CONFIG" ]]; then
        log "${YELLOW}! 系统提示词已存在，跳过安装${NC}"
    else
        log "${YELLOW}! 无法写入系统提示词，请手动创建:${NC}"
        log "  mkdir -p ~/Library/Application\\ Support/Claude"
        log "  nano ~/Library/Application\\ Support/Claude/system_prompt.txt"
        log "  # 然后将以下内容粘贴进去"
        log ""
        echo "$SYSTEM_PROMPT_CONTENT"
    fi
fi

# ── 安装开机自动汉化 ─────────────────────────────────────────
AUTO_LAUNCH_PLIST="$HOME/Library/LaunchAgents/com.claude-zh-CN.auto-launch.plist"
AUTO_LAUNCH_SCRIPT="$SCRIPT_DIR/claude-zh-autolaunch.sh"

log ""
log "${CYAN}── 步骤 5/5: 开机自动汉化设置 ────────────────────"
log ""

if [[ ! -f "$AUTO_LAUNCH_PLIST" ]]; then
    # 创建 autolaunch 脚本
    cat > "$AUTO_LAUNCH_SCRIPT" << 'AUTOLAUNCH_EOF'
#!/bin/bash
# Claude Desktop 开机自动汉化脚本
# 由 com.claude-zh-CN.auto-launch.plist 调用

sleep 30  # 等待 30 秒，确保 Claude 已启动

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_OUTPUT=$("$SCRIPT_DIR/patch_js.py" --check 2>&1)

if echo "$CHECK_OUTPUT" | grep -q "需要重新汉化"; then
    # 仅当汉化失效时才重新打补丁
    sudo "$SCRIPT_DIR/patch_js.py" 2>/dev/null || true
fi
AUTOLAUNCH_EOF

    chmod +x "$AUTO_LAUNCH_SCRIPT"
    
    # 创建 LaunchAgent plist
    cat > "$AUTO_LAUNCH_PLIST" << PLIST_EOF
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
        <string>$AUTO_LAUNCH_SCRIPT</string>
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
    
    # 加载 LaunchAgent
    launchctl load "$AUTO_LAUNCH_PLIST" 2>/dev/null || true
    
    log "${GREEN}✓ 开机自动汉化已启用${NC}"
    log "  每次开机后，脚本会自动检测并重新汉化（如果失效）"
    log "  自动检查间隔: 开机后 30 秒"
    log "  日志位置: /tmp/claude-zh-autolaunch.log"
    log "  如需卸载自动汉化: bash claude-zh-CN.sh --uninstall-auto"
else
    log "${YELLOW}! 开机自动汉化已存在，跳过安装${NC}"
fi

# ── 完成 ──────────────────────────────────────────────────────────
log ""
log "${GREEN}========================================${NC}"
log "${GREEN}  ✓ 设置完成！${NC}"
log "${GREEN}========================================${NC}"
log ""
log "  已启用功能:"
log "    ✓ 界面汉化（16,000+ 条中文字符串）"
log "    ✓ AI 交互中文（Chat/Cowork/Code 模式）${NC}"
log "    ✓ 开机自动检测与修复汉化失效${NC}"
log ""
log "  下一步:"
log "    1. 完全退出 Claude（Cmd + Q）"
log "    2. 重新打开 Claude"
log "    3. 界面为简体中文，AI 交互全程中文${NC}"
log ""
log "  手动检查汉化状态:"
log "    python3 patch_js.py --check"
log ""
log "  卸载开机自动汉化:"
log "    bash claude-zh-CN.sh --uninstall-auto"
log ""
