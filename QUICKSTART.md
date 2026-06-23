# Claude Desktop 简体中文汉化 — 一键安装脚本 v2.6

本项目提供 Claude Desktop (macOS) 的一键汉化解�品的套件：

## 快速使用

### 安装汉化
```bash
cd Claude-Chinese-Toolkit
sudo bash claude-zh-CN.sh --install
```

### 卸载汉化
```bash
sudo bash claude-zh-CN.sh --uninstall
```

### 一键重装（推荐，Claude 更新后用）
```bash
sudo bash claude-zh-CN.sh --reinstall
```

### 检查状态
```bash
bash claude-zh-CN.sh --check
```

## 脚本说明

| 脚本 | 用途 |
|------|------|
| `claude-zh-CN.sh` | 主脚本：安装/卸载/重装/检查 |
| `uninstall.sh` | 独立卸载脚本 |
| `install.sh` | 独立安装脚本（供 curl pipe 使用） |
| `claude-zh-autolaunch.sh` | 开机自动检测脚本 |
| `patch_js.py` | Python 汉化补丁引擎 |
| `language-pack/` | 翻译文件目录 |
