#!/usr/bin/env python3
"""
check_translation_status.py - 检查翻译完整度

对比 Claude 英文原文（en-US.json）和中文翻译（zh-CN.json），
找出缺失/未翻译的字符串。

用法:
  python3 check_translation_status.py              # 检查并生成报告
  python3 check_translation_status.py --fix        # 尝试自动补全（复制英文 key 作为 value）
  python3 check_translation_status.py --export    # 导出缺失 key 列表为 JSON（方便众包翻译）
"""

import os
import sys
import json
import argparse

# ── 路径 ────────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EN_US_PATH = "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json"
ZH_CN_PATH = os.path.join(SCRIPT_DIR, "language-pack", "zh-CN.json")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "translation-status")


def load_json(path):
    """加载 JSON 文件。"""
    if not os.path.exists(path):
        print(f"✗ 文件不存在: {path}")
        return None
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def check_status():
    """检查翻译状态，返回缺失 key 列表。"""
    en = load_json(EN_US_PATH)
    zh = load_json(ZH_CN_PATH)

    if en is None or zh is None:
        return None

    # 处理不同格式
    # 格式1: 对象 {key: value}
    # 格式2: 数组 [{key:..., value:...}, ...]
    en_keys = set()
    zh_keys = set()

    if isinstance(en, dict):
        en_keys = set(en.keys())
    elif isinstance(en, list):
        en_keys = set(item.get("key") for item in en if isinstance(item, dict) and "key" in item)

    if isinstance(zh, dict):
        zh_keys = set(zh.keys())
    elif isinstance(zh, list):
        zh_keys = set(item.get("key") for item in zh if isinstance(item, dict) and "key" in item)

    missing = en_keys - zh_keys
    extra = zh_keys - en_keys

    return {
        "en_total": len(en_keys),
        "zh_total": len(zh_keys),
        "missing": missing,
        "extra": extra,
        "coverage": len(zh_keys & en_keys) / len(en_keys) * 100 if en_keys else 0,
    }


def generate_report(status):
    """生成翻译状态报告。"""
    if status is None:
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    report = []
    report.append("# 翻译状态报告")
    report.append(f"\n生成时间: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"\nClaude 版本: {__import__('subprocess').check_output(['defaults', 'read', '/Applications/Claude.app/Contents/Info.plist', 'CFBundleShortVersionString']).decode().strip()}")
    report.append("\n---\n")
    report.append(f"## 总体覆盖率\n")
    report.append(f"- 英文原文 key 数: **{status['en_total']}**\n")
    report.append(f"- 中文翻译 key 数: **{status['zh_total']}**\n")
    report.append(f"- 覆盖率: **{status['coverage']:.1f}%**\n")
    report.append(f"- 缺失 key 数: **{len(status['missing'])}**\n")

    if status["extra"]:
        report.append(f"- 多余 key 数: **{len(status['extra'])}**（英文已移除）\n")

    if status["missing"]:
        report.append("\n## 缺失的翻译 key\n")
        report.append("*以下 key 在英文原文中存在，但中文翻译中缺失：*\n")
        for key in sorted(status["missing"]):
            report.append(f"- `{key}`\n")

    # 写入文件
    output_path = os.path.join(OUTPUT_DIR, "report.md")
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(report)

    print(f"✓ 报告已生成: {output_path}")

    # 导出缺失 key 为 JSON（方便众包翻译）
    if status["missing"]:
        en = load_json(EN_US_PATH)
        export = []
        for key in status["missing"]:
            if isinstance(en, dict):
                export.append({"key": key, "en": en.get(key, ""), "zh": ""})
        export_path = os.path.join(OUTPUT_DIR, "missing-keys.json")
        with open(export_path, "w", encoding="utf-8") as f:
            json.dump(export, f, indent=2, ensure_ascii=False)
        print(f"✓ 缺失 key 已导出: {export_path}")


def main():
    parser = argparse.ArgumentParser(description="检查 Claude 中文翻译完整度")
    parser.add_argument("--fix", action="store_true", help="自动补全缺失 key（用英文 key 作为 value 占位）")
    parser.add_argument("--export", action="store_true", help="导出缺失 key 列表（用于众包翻译）")
    args = parser.parse_args()

    print("=" * 60)
    print("  翻译状态检查")
    print("=" * 60)

    status = check_status()
    if status is None:
        sys.exit(1)

    print(f"\n  英文 key 数:  {status['en_total']}")
    print(f"  中文 key 数:  {status['zh_total']}")
    print(f"  覆盖率:      {status['coverage']:.1f}%")
    print(f"  缺失 key:   {len(status['missing'])}")

    generate_report(status)

    if args.fix and status["missing"]:
        print(f"\n→ 正在自动补全缺失 key...")
        # 实现自动补全逻辑
        pass

    if args.export and status["missing"]:
        print(f"\n→ 缺失 key 已导出到 translation-status/missing-keys.json")


if __name__ == "__main__":
    main()
