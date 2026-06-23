# Claude Desktop 简体中文汉化 v2.6 — 一键安装

本项目提供 Claude Desktop (macOS) 的一键汉化解��包，特色是 **真正的"一键安装、一键卸载"**。

## 🚀 快速开始

```bash
# 安装汉化
sudo bash claude-zh-CN.sh --install

# 卸载汉化
sudo bash claude-zh-CN.sh --uninstall

# 一键重装（Claude 更新后用）
sudo bash claude-zh-CN.sh --reinstall
```

## ✨ v2.6 特性

- **一键安装**：一条命令搞定
- **一键卸载**：完全清理不留痕迹
- **一键重装**：自动先卸载再安装
- **自动检测修复**：开机自动修复汉化失效
- **系统提示词**：AI 全程中文交流
- **安装清单**：记录所有文件，卸载时反向清理

## 📦 安装方式

### Homebrew（推荐）
```bash
brew tap xiaoxianxian/claude-zh
brew install claude-zh
claude-zh
```

### 本地脚本
```bash
cd Claude-Chinese-Toolkit
sudo bash claude-zh-CN.sh --install
```

### Download ZIP
```bash
curl -LO https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/archive/refs/heads/main.zip
unzip main.zip
cd Claude-Chinese-Toolkit-main
sudo bash claude-zh-CN.sh --install
```

## 🔧 更多命令

```bash
bash claude-zh-CN.sh --help            # 帮助
bash claude-zh-CN.sh --check           # 检查状态
sudo bash claude-zh-CN.sh --install --no-ai  # 仅汉化界面
sudo bash claude-zh-CN.sh --uninstall-auto  # 卸载自动检测
```

## 🎯 功能清单

| 功能 | 说明 |
|------|------|
| 界面汉化 | 16,000+ 条中文字符串 |
| AI 交互中文 | Chat/Cowork/Code 全程中文 |
| 开机自动检测 | 自动修复汉化失效 |
| 一键卸载 | 清除所有汉化痕迹 |
| 安装清单 | 反向清理 |

## ⚠️ 已知限制

- 部分新增字符串可能暂无翻译
- LaunchAgent 加载可能在部分系统上失败（不影响功能）
- Claude 更新后可能需要重新安装

## 📝 更新日志

### v2.6 (2026-06-23)
- ✅ 新增一键安装、卸载、重装功能
- ✅ 新增安装清单系统
- ✅ 修复 LaunchAgent 加载问题
- ✅ 新增独立安装/卸载脚本

### v2.5 (2026-06-19)
- ✅ 新增开机自动检测与修复
- ✅ 新增系统提示词安装

## 📄 许可证

MIT License
