# Claude-Chinese-Toolkit Homebrew Formula
#
# 安装方式：
#   brew tap xiaoxianxian/claude-zh
#   brew install claude-zh
#
# 或从本 repo 本地安装：
#   brew install --build-from-source ./claude-zh.rb

class ClaudeZh < Formula
  desc "Claude Desktop (macOS) 简体中文汉化工具"
  homepage "https://github.com/xiaoxianxian/Claude-Chinese-Toolkit"
  url "https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/archive/refs/tags/v2.3.tar.gz"
  sha256 "PLACEHOLDER_REPLACE_WITH_ACTUAL_SHA256"  # 发布后替换
  license "MIT"

  depends_on "python@3.9"

  def install
    # 安装 patch_js.py 和 language-pack/ 到 share/claude-zh/
    (share/"claude-zh").install "patch_js.py"
    (share/"claude-zh").install "language-pack"

    # 创建包装脚本 claude-zh
    (bin/"claude-zh").write <<~EOS
#!/bin/bash
# Claude-Chinese-Toolkit 汉化脚本（Homebrew 安装版）
# 用法: sudo claude-zh

set -euo pipefail
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
CYAN='\\033[0;36m'
NC='\\033[0m'

log() { echo -e "$1"; }

if [[ ! -d "/Applications/Claude.app" ]]; then
  log "${RED}✗ 未找到 /Applications/Claude.app${NC}"
  log "  请先安装 Claude Desktop"
  exit 1
fi

log "${CYAN}Claude-Chinese-Toolkit (Homebrew 安装版)${NC}"
log "Claude 版本: $(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo '未知')"
log ""

if pgrep -x "Claude" > /dev/null 2>&1; then
  log "${YELLOW}→ Claude 正在运行，正在退出...${NC}"
  killall Claude 2>/dev/null || true
  sleep 2
  if pgrep -x "Claude" > /dev/null 2>&1; then
    log "${RED}✗ 无法退出 Claude，请手动 Cmd+Q 关闭后重试${NC}"
    exit 1
  fi
fi
log "${GREEN}✓ Claude 已退出${NC}"

log ""
log "${CYAN}→ 需要 sudo 权限来修改 Claude.app 文件...${NC}"
log ""

sudo python3 "#{share/"claude-zh"/"patch_js.py"}"
EOS
    chmod 0755, bin/"claude-zh"
  end

  def caveats
    <<~EOS
✅ Claude-Chinese-Toolkit 已安装！

  使用方法：
    sudo claude-zh          # 完整运行（推荐）
    claude-zh --check      # 检查是否需要重新汉化

  注意事项：
  - 运行前确保 Claude 完全退出（Cmd+Q）
  - 每次 Claude 版本更新后需重新运行
  - 翻译文件随 Claude 版本更新，请定期运行 `brew upgrade claude-zh` 更新翻译

  卸载：
    brew uninstall claude-zh
    sudo rm /Applications/Claude.app/Contents/Resources/zh-CN.json
    sudo rm /Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json

    EOS
  end

  test do
    assert_predicate bin/"claude-zh", :executable?
    assert_predicate share/"claude-zh/patch_js.py", :exist?
    assert_predicate share/"claude-zh/language-pack/zh-CN.json", :exist?
  end
end
