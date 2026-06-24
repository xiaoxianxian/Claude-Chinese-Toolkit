#!/usr/bin/env python3
"""
patch_js.py - Claude Desktop (macOS) 简体中文汉化补丁
自动检测版本，应用 JS 补丁并安装翻译文件。

用法:
  sudo python3 patch_js.py          # 完整运行（推荐）
  python3 patch_js.py --dry-run   # 仅预览，不修改文件
  python3 patch_js.py --check      # 检查是否需要重新汉化
  python3 patch_js.py --version    # 显示版本信息
"""

import os
import sys
import glob
import re
import shutil
import argparse
import json
import hashlib
from datetime import datetime

# ── 路径 ────────────────────────────────────────────────────────────────────
JS_DIR = "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1"
RESOURCES_DIR = "/Applications/Claude.app/Contents/Resources"
I18N_DIR = os.path.join(RESOURCES_DIR, "ion-dist", "i18n")
CONFIG_PATH = os.path.expanduser("~/Library/Application Support/Claude/config.json")
STATE_DIR = os.path.expanduser("~/.claude-zh-cn")
STATE_FILE = os.path.join(STATE_DIR, "state.json")


def get_claude_version():
    """从 Info.plist 获取 Claude 版本号。"""
    plist = "/Applications/Claude.app/Contents/Info.plist"
    if not os.path.exists(plist):
        return "unknown"
    try:
        import plistlib
        with open(plist, "rb") as f:
            info = plistlib.load(f)
        return info.get("CFBundleShortVersionString", "unknown")
    except Exception:
        return "unknown"


def get_file_hash(filepath):
    """计算文件的 SHA-256 哈希。"""
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()[:16]


def load_state():
    """加载状态文件。"""
    if not os.path.exists(STATE_FILE):
        return {}
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return {}


def save_state(state):
    """保存状态文件。"""
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)


def check_needs_repatch(js_file):
    """
    检查是否需要重新打补丁。
    返回: (needs_repatch: bool, reason: str)
    """
    state = load_state()

    # 检查状态文件是否存在
    if not state:
        return True, "首次运行"

    # 检查 Claude 版本是否变化
    current_version = get_claude_version()
    saved_version = state.get("claude_version", "")
    if current_version != saved_version:
        return True, f"Claude 版本变化: {saved_version} → {current_version}"

    # 检查 JS 文件是否变化（通过 hash）
    current_hash = get_file_hash(js_file)
    saved_hash = state.get("js_hash", "")
    if current_hash != saved_hash:
        return True, "JS 文件已被 Claude 更新替换"

    # 检查补丁是否仍然生效（支持多版本模式）
    with open(js_file, "r") as f:
        content = f.read()
    # v1.15200.0+: mRt="zh-CN"
    # v1.14271.0+: Hzt="zh-CN"
    # 旧版: GTt="zh-CN"
    has_patch1 = 'mRt="zh-CN"' in content or 'Hzt="zh-CN"' in content or 'GTt="zh-CN"' in content
    if not has_patch1:
        return True, "JS 补丁1 未生效（locale 未硬编码）"
    # documentElement.lang
    has_lang_hardcoded = 'documentElement.lang="zh-CN"' in content
    if not has_lang_hardcoded and 'documentElement.lang=mRt' in content:
        return True, "JS 补丁2c 未生效（documentElement.lang 未硬编码 mRt）"
    if not has_lang_hardcoded and 'documentElement.lang=Hzt' in content:
        return True, "JS 补丁2c 未生效（documentElement.lang 未硬编码 Hzt）"
    # Bzt 阻断
    if 'if(e||!s?.locale)return' in content:
        return True, "JS 补丁2b 未生效（Bzt 阻断未移除）"

    return False, "补丁已生效，无需重新汉化"


def print_status():
    """打印当前汉化状态（--check 模式）。"""
    if not os.path.isdir("/Applications/Claude.app"):
        print("✗ Claude.app 未安装")
        return False

    js_file = find_js_file()
    needs, reason = check_needs_repatch(js_file)

    print("── 汉化状态 ─────────────────────────────────────────")
    print(f"  Claude 版本:  {get_claude_version()}")
    print(f"  JS 文件:      {os.path.basename(js_file)}")

    state = load_state()
    if state.get("last_patched"):
        print(f"  上次汉化:    {state['last_patched']}")

    print()
    if needs:
        print(f"⚠️  需要重新汉化")
        print(f"  原因: {reason}")
        print()
        print(f"  运行以下命令重新汉化:")
        print(f"    bash claude-zh-CN.sh")
        print(f"  或手动在终端执行:")
        print(f'    sudo python3 patch_js.py')
        return False
    else:
        print(f"✓ 汉化状态正常")
        return True


def find_js_file():
    """自动查找当前版本的 JS bundle 文件。"""
    files = sorted(glob.glob(os.path.join(JS_DIR, "index-*.js")))
    if not files:
        print("  ✗ 未找到 JS bundle（/Applications/Claude.app/.../index-*.js）")
        print("  Claude 可能未安装或路径已变更。")
        sys.exit(1)
    return files[0]


def find_language_pack():
    """查找 language-pack 目录（支持从源码运行和 Homebrew 安装后运行）。"""
    # 方式1: 与脚本同目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    lp = os.path.join(script_dir, "language-pack")
    if os.path.isdir(lp):
        return lp

    # 方式2: Homebrew 安装位置 $(prefix)/share/claude-zh/language-pack
    prefix = os.environ.get("HOMEBREW_PREFIX", "")
    if not prefix:
        # 尝试自动检测 Homebrew prefix
        for p in ["/opt/homebrew", "/usr/local"]:
            if os.path.isdir(os.path.join(p, "share", "claude-zh")):
                prefix = p
                break
    if prefix:
        lp = os.path.join(prefix, "share", "claude-zh", "language-pack")
        if os.path.isdir(lp):
            return lp

    # 方式3: 相对路径（brew 安装后 bin/ 和 share/ 分开）
    for p in [
        os.path.join(os.path.dirname(script_dir), "share", "claude-zh", "language-pack"),
        "/usr/local/share/claude-zh/language-pack",
        "/opt/homebrew/share/claude-zh/language-pack",
    ]:
        if os.path.isdir(p):
            return p

    return None


def install_translations(script_dir):
    """复制中文翻译文件到 Claude 资源目录。"""
    lp = find_language_pack()
    if lp is None:
        print("  ✗ 未找到 language-pack/ 目录")
        print("    请确保 language-pack/ 与脚本在同一目录，或设置 HOMEBREW_PREFIX 环境变量")
        return False
    ok = True

    # 后端翻译（桌面端菜单/对话框）
    src = os.path.join(lp, "desktop-shell-zh-CN.json")
    dst = os.path.join(RESOURCES_DIR, "zh-CN.json")
    if os.path.exists(src):
        shutil.copy(src, dst)
        print(f"  ✓ 后端翻译 → zh-CN.json")
    else:
        print(f"  ✗ 缺失: language-pack/desktop-shell-zh-CN.json")
        ok = False

    # 前端翻译（SPA i18n）
    src = os.path.join(lp, "zh-CN.json")
    dst = os.path.join(I18N_DIR, "zh-CN.json")
    os.makedirs(I18N_DIR, exist_ok=True)
    if os.path.exists(src):
        shutil.copy(src, dst)
        print(f"  ✓ 前端翻译 → ion-dist/i18n/zh-CN.json")
    else:
        print(f"  ✗ 缺失: language-pack/zh-CN.json")
        ok = False

    return ok


def patch_js(filepath, dry_run=False):
    """
    对 JS bundle 应用两个补丁：
    1. 硬编码 GTt = "zh-CN"（初始 locale，绕过浏览器语言检测）
    2. 阻止 API 回调覆盖 locale（将 s.locale 替换为固定值）
    """
    with open(filepath, "r") as f:
        content = f.read()

    original = content
    applied = []

    # ── 补丁 1: 硬编码初始 locale ────────────────────────────────────────
    # Claude 1.15200.0+ 使用 pRt/mRt:
    # pRt="spa:locale",mRt=xE([(()=>{try{return localStorage.getItem(pRt)}catch{return null}})(),...navigator.languages])
    # 需要替换为: pRt="spa:locale",mRt="zh-CN"
    
    p1_new_v15200 = 'pRt="spa:locale",mRt="zh-CN"'
    p1_old_v15200 = 'mRt=xE([(()=>{try{return localStorage.getItem(pRt)}catch{return null}})(),...navigator.languages])'
    
    if p1_old_v15200 in content:
        content = content.replace(p1_old_v15200, 'mRt="zh-CN"')
        applied.append("补丁1: mRt 硬编码为 zh-CN (v1.15200.0+)")
    elif 'mRt="zh-CN"' in content:
        applied.append("补丁1: 已应用，跳过")
    else:
        # Claude 1.14271.0+ 使用 Hzt/mN:
        p1_old = 'const Uzt="spa:locale",Hzt=mN([(()=>{try{return localStorage.getItem(Uzt)}catch{return null}})(),...navigator.languages])'
        p1_new = 'const Uzt="spa:locale",Hzt="zh-CN"'
        
        if p1_old in content:
            content = content.replace(p1_old, p1_new)
            applied.append("补丁1: Hzt 硬编码为 zh-CN (v1.14271.0+)")
        elif 'GTt="zh-CN"' in content:
            applied.append("补丁1: 已应用，跳过")
        else:
            # 回退到旧模式
            p1_fallback = re.compile(r'GTt=\w+\(\[.*?navigator\.languages.*?\]\)')
            m1 = p1_fallback.search(content)
            if m1:
                content = content[:m1.start()] + 'GTt="zh-CN"' + content[m1.end():]
                applied.append("补丁1: GTt 硬编码为 zh-CN (旧版)")
            elif 'GTt="zh-CN"' in content:
                applied.append("补丁1: 已应用，跳过")
            else:
                print(f"  ✗ 补丁1: 未找到匹配模式（Claude 版本可能不兼容）")
                print(f"     请在 GitHub 提 issue 并附上 JS 文件名")
                return False

    # ── 补丁 2: 阻止 API 覆盖 + 移除 Bzt 阻断 ────────────────────────────
    # 2a. 阻止 API 回调覆盖 (旧版补丁)
    p2 = re.compile(r'const n=\w+\(\[s\.locale\]\)')
    m2 = p2.search(content)
    if m2:
        content = content[:m2.start()] + 'const n=PS(["zh-CN"])' + content[m2.end():]
        applied.append("补丁2: API locale 覆盖已阻止")
    elif 'const n=PS(["zh-CN"])' in content or 'const n=VS(["zh-CN"])' in content:
        applied.append("补丁2: 已应用，跳过")
    else:
        print(f"  ✗ 补丁2: 未找到匹配模式（Claude 版本可能不兼容）")

    # 2b. 移除 Bzt 函数中的阻断 (Claude 1.14271.0+ 新增)
    # 原始: if(e||!s?.locale)return;
    # 含义: 如果 s 没有 locale 属性，直接 return，不执行 zh-CN 设置
    blocker = 'if(e||!s?.locale)return'
    if blocker in content:
        content = content.replace(blocker, 'if(e)return')
        applied.append("补丁2b: 移除 Bzt 中的 !s?.locale 阻断")
    
    # 2c. 硬编码 documentElement.lang
    # Claude 1.15200.0+ 直接使用 mRt 变量引用
    old_lang_v15200 = 'documentElement.lang=mRt'
    if old_lang_v15200 in content:
        content = content.replace(old_lang_v15200, 'documentElement.lang="zh-CN"')
        applied.append("补丁2c: documentElement.lang 硬编码为 zh-CN (v1.15200.0+)")
    elif 'documentElement.lang="zh-CN"' in content:
        if not any('zh-CN' in a for a in applied if '2c' in a):
            applied.append("补丁2c: 已应用，跳过")
    else:
        # 旧版使用 Hzt 变量
        old_lang = 'documentElement.lang=Hzt'
        new_lang = 'documentElement.lang="zh-CN"'
        if old_lang in content:
            content = content.replace(old_lang, new_lang)
            applied.append("补丁2c: documentElement.lang 硬编码为 zh-CN (旧版)")
        elif 'documentElement.lang="zh-CN"' in content:
            applied.append("补丁2c: 已应用，跳过")

    # ── 写入或 dry-run ────────────────────────────────────────────────────
    if dry_run:
        print(f"\n  [dry-run] 以下补丁将被应用（未实际修改文件）:")
        for a in applied:
            print(f"    ✓ {a}")
        return True

    if content != original:
        # 先备份
        bak = filepath + ".bak"
        with open(bak, "w") as f:
            f.write(original)
        print(f"  备份: {os.path.basename(bak)}")

        with open(filepath, "w") as f:
            f.write(content)
        print(f"  已更新: {os.path.basename(filepath)}")

    for a in applied:
        print(f"  ✓ {a}")

    return True


def patch_config():
    """尝试修改 config.json 中的 locale 字段。"""
    if not os.path.exists(CONFIG_PATH):
        print(f"  ! {CONFIG_PATH} 不存在，跳过")
        return

    try:
        with open(CONFIG_PATH, "r") as f:
            c = f.read()
        if '"locale": "en-US"' in c:
            c = c.replace('"locale": "en-US"', '"locale": "zh-CN"')
            with open(CONFIG_PATH, "w") as f:
                f.write(c)
            print("  ✓ config.json locale → zh-CN")
        elif '"locale": "zh-CN"' in c:
            print("  ! config.json 已是 zh-CN，跳过")
        else:
            print('  ! config.json 中无 locale 字段，跳过')
    except PermissionError:
        print(f"  ✗ 权限不足: {CONFIG_PATH}")
        print(f"    请手动将 \"locale\": \"en-US\" 改为 \"locale\": \"zh-CN\"")


def save_success_state(js_file):
    """保存成功的汉化状态。"""
    state = {
        "claude_version": get_claude_version(),
        "js_file": js_file,
        "js_hash": get_file_hash(js_file),
        "patched": True,
        "last_patched": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    save_state(state)


def main():
    parser = argparse.ArgumentParser(description="Claude Desktop 简体中文汉化")
    parser.add_argument("--dry-run", action="store_true", help="仅预览，不修改文件")
    parser.add_argument("--check", action="store_true", help="检查是否需要重新汉化")
    parser.add_argument("--version", action="version", version="Claude-Chinese-Toolkit v2.3")
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))

    # ── --check 模式 ────────────────────────────────────────────────────
    if args.check:
        ok = print_status()
        sys.exit(0 if ok else 1)

    print("=" * 60)
    print("  Claude Desktop 简体中文汉化脚本")
    print("=" * 60)

    # ── 检查 Claude.app ────────────────────────────────────────────────────
    if not os.path.isdir("/Applications/Claude.app"):
        print("\n✗ /Applications/Claude.app 未找到")
        print("  请先安装 Claude Desktop")
        sys.exit(1)
    print("\n✓ Claude.app 已找到")

    # ── 版本检测提醒 ──────────────────────────────────────────────────────
    state = load_state()
    if state.get("claude_version"):
        current = get_claude_version()
        saved = state.get("claude_version")
        if current != saved:
            print(f"\n⚠️  检测到 Claude 版本变化: {saved} → {current}")
            print(f"   正在重新应用汉化补丁...")

    # ── 检查 Claude 是否在运行 ───────────────────────────────────────────
    if os.system("pgrep -x Claude >/dev/null 2>&1") == 0:
        print("\n! Claude 正在运行，请先 Cmd+Q 完全退出 Claude")
        print("  脚本已自动尝试退出，如仍运行请手动关闭。")
        os.system("killall Claude 2>/dev/null")
        import time
        time.sleep(2)
        if os.system("pgrep -x Claude >/dev/null 2>&1") == 0:
            print("✗ 无法退出 Claude，请手动关闭后重试")
            sys.exit(1)

    # ── 步骤 1: 安装翻译文件 ──────────────────────────────────────────
    print("\n── 步骤 1/3: 安装翻译文件 ──────────────────────────────")
    install_translations(script_dir)

    # ── 步骤 2: JS 补丁 ───────────────────────────────────────────────
    print("\n── 步骤 2/3: 修改前端 JS ────────────────────────────────")
    js_file = find_js_file()
    print(f"  目标文件: {os.path.basename(js_file)}")

    # 移除 macOS 文件保护
    os.system(f'xattr -c "{js_file}" 2>/dev/null')
    os.system(f'chflags nouchg "{js_file}" 2>/dev/null')

    patch_js(js_file, dry_run=args.dry_run)

    # ── 步骤 3: config.json ────────────────────────────────────────────
    print("\n── 步骤 3/3: 修改 config.json ───────────────────────────")
    patch_config()

    # ── 保存状态 ────────────────────────────────────────────────────────
    if not args.dry_run:
        save_success_state(js_file)

    # ── 完成 ────────────────────────────────────────────────────────────
    if not args.dry_run:
        print("\n" + "=" * 60)
        print("  ✓ 汉化完成！")
        print("=" * 60)
        print("\n  下一步:")
        print("    1. 完全退出 Claude（Cmd + Q）")
        print("    2. 重新打开 Claude")
        print("    3. 界面应为简体中文\n")
        print("  以后 Claude 更新后变回英文，重新运行本脚本即可\n")
        print("  查看状态:")
        print(f"    python3 {os.path.basename(__file__)} --check\n")
    else:
        print("\n  [dry-run] 未实际修改文件，移除 --dry-run 后重新运行")


if __name__ == "__main__":
    main()
