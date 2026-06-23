# Claude-Chinese-Toolkit 安装指南

本指南介绍如何通过不同方式安装 Claude Desktop 简体中文汉化。

## 系统要求

- macOS 12.0+ (Big Sur 及以上)
- Claude Desktop 1.14271.0+ (已测试)
- Python 3.9+
- git (可选，用于从源码安装)

## 方式一：Homebrew 安装（推荐新手）

```bash
# 添加 tap
brew tap xiaoxianxian/claude-zh

# 安装
brew install claude-zh

# 运行汉化
claude-zh
```

**优点**：自动处理依赖，一键安装/卸载/更新
**缺点**：仅支持 Homebrew 用户

## 方式二：本地脚本安装（适合开发者）

```bash
# 克隆仓库
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit

# 运行安装
sudo bash claude-zh-CN.sh --install

# 如需卸载
sudo bash claude-zh-CN.sh --uninstall
```

## 方式三：Download ZIP

```bash
# 下载 ZIP
curl -LO https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/archive/refs/heads/main.zip
unzip main.zip
cd Claude-Chinese-Toolkit-main

# 运行安装
sudo bash claude-zh-CN.sh --install
```

## 安装后的功能

安装完成后你将获得：

1. **界面汉化**：16,000+ 条中文字符串，覆盖 Claude 整个界面
2. **AI 交互中文**：Chat / Cowork / Code 模式下全程中文交流
3. **开机自动检测**：每次开机自动修复汉化失效

## 常见问题

### Q: Claude 更新后变回英文怎么办？

运行：
```bash
sudo bash claude-zh-CN.sh --reinstall
```

### Q: 只想汉化界面，不想让 AI 用中文？

运行：
```bash
sudo bash claude-zh-CN.sh --install --no-ai
```

### Q: 如何彻底卸载？

运行：
```bash
sudo bash claude-zh-CN.sh --uninstall
```

### Q: 如何检查汉化状态？

运行：
```bash
bash claude-zh-CN.sh --check
```
