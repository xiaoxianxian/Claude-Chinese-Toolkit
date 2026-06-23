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
