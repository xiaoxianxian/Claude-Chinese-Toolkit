#!/usr/bin/env python3
"""
patch_js.py - Claude Desktop (macOS) 简体中文汉化补丁
自动检测版本，应用 JS 补丁并安装翻译文件。

用法:
  sudo python3 patch_js.py          # 完整运行（推荐）
  python3 patch_js.py --dry-run   # 仅预览，不修改文件
"""

import os
import sys
import glob
import re
import shutil
import argparse

# ── 路径 ────────────────────────────────────────────────────────────────────
JS_DIR = "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1"
RESOURCES_DIR = "/Applications/Claude.app/Contents/Resources"
I18N_DIR = os.path.join(RESOURCES_DIR, "ion-dist", "i18n")
CONFIG_PATH = os.path.expanduser("~/Library/Application Support/Claude/config.json")


def find_js_file():
    """自动查找当前版本的 JS bundle 文件。"""
    files = sorted(glob.glob(os.path.join(JS_DIR, "index-*.js")))
    if not files:
        print("  ✗ 未找到 JS bundle（/Applications/Claude.app/.../index-*.js）")
        print("  Claude 可能未安装或路径已变更。")
        sys.exit(1)
    return files[0]


def install_translations(script_dir):
    """复制中文翻译文件到 Claude 资源目录。"""
    lp = os.path.join(script_dir, "language-pack")
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
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    applied = []

    # ── 补丁 1: 硬编码初始 locale ────────────────────────────────────────
    # 匹配: GTt=任意函数名([...navigator.languages])
    # 例如: GTt=VS([(...),...navigator.languages]) 或 GTt=PS([(...),...navigator.languages])
    p1 = re.compile(r'GTt=\w+\(\[.*?navigator\.languages.*?\]\)')
    m1 = p1.search(content)
    if m1:
        content = content[:m1.start()] + 'GTt="zh-CN"' + content[m1.end():]
        applied.append("补丁1: GTt 硬编码为 zh-CN")
    elif 'GTt="zh-CN"' in content:
        applied.append("补丁1: 已应用，跳过")
    else:
        print(f"  ✗ 补丁1: 未找到匹配模式（Claude 版本可能不兼容）")
        print(f"     请在 GitHub 提 issue 并附上 JS 文件名")

    # ── 补丁 2: 阻止 API 覆盖 ────────────────────────────────────────────
    # 在 YTt 函数中，将 const n=任意函数名([s.locale]) 替换为固定值
    # 上下文: WV().then(s=>{...const n=PS([s.locale]);...})
    p2 = re.compile(r'const n=\w+\(\[s\.locale\]\)')
    m2 = p2.search(content)
    if m2:
        content = content[:m2.start()] + 'const n=PS(["zh-CN"])' + content[m2.end():]
        applied.append("补丁2: API locale 覆盖已阻止")
    elif 'const n=PS(["zh-CN"])' in content or 'const n=VS(["zh-CN"])' in content:
        applied.append("补丁2: 已应用，跳过")
    else:
        print(f"  ✗ 补丁2: 未找到匹配模式（Claude 版本可能不兼容）")

    # ── 写入或 dry-run ────────────────────────────────────────────────────
    if dry_run:
        print(f"\n  [dry-run] 以下补丁将被应用（未实际修改文件）:")
        for a in applied:
            print(f"    ✓ {a}")
        return True

    if content != original:
        # 先备份
        bak = filepath + ".bak"
        with open(bak, 'w') as f:
            f.write(original)
        print(f"  备份: {os.path.basename(bak)}")

        with open(filepath, 'w') as f:
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
        with open(CONFIG_PATH, 'r') as f:
            c = f.read()
        if '"locale": "en-US"' in c:
            c = c.replace('"locale": "en-US"', '"locale": "zh-CN"')
            with open(CONFIG_PATH, 'w') as f:
                f.write(c)
            print("  ✓ config.json locale → zh-CN")
        elif '"locale": "zh-CN"' in c:
            print("  ! config.json 已是 zh-CN，跳过")
        else:
            print('  ! config.json 中无 locale 字段，跳过')
    except PermissionError:
        print(f"  ✗ 权限不足: {CONFIG_PATH}")
        print(f"    请手动将 \"locale\": \"en-US\" 改为 \"locale\": \"zh-CN\"")


def main():
    parser = argparse.ArgumentParser(description="Claude Desktop 简体中文汉化")
    parser.add_argument("--dry-run", action="store_true", help="仅预览，不修改文件")
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))

    print("=" * 60)
    print("  Claude Desktop 简体中文汉化脚本")
    print("=" * 60)

    # ── 检查 Claude.app ────────────────────────────────────────────────────
    if not os.path.isdir("/Applications/Claude.app"):
        print("\n✗ /Applications/Claude.app 未找到")
        print("  请先安装 Claude Desktop")
        sys.exit(1)
    print("\n✓ Claude.app 已找到")

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

    # ── 完成 ────────────────────────────────────────────────────────────
    if not args.dry_run:
        print("\n" + "=" * 60)
        print("  ✓ 汉化完成！")
        print("=" * 60)
        print("\n  下一步:")
        print("    1. 完全退出 Claude（Cmd + Q）")
        print("    2. 重新打开 Claude")
        print("    3. 界面应为简体中文\n")
        print("  如需恢复:")
        print(f"    将 {os.path.basename(js_file)}.bak 复制回原位置")
        print("    并删除 Resources/zh-CN.json 和 ion-dist/i18n/zh-CN.json\n")


if __name__ == "__main__":
    main()
