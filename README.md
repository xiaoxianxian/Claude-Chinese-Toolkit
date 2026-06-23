# Claude Desktop 简体中文汉化 v2.6.1

> 一键安装 / 一键卸载 / 一键重装 — macOS 平台最完整的 Claude Desktop 汉化工具

本项目为 [Claude Desktop](https://claude.ai/download) (macOS) 提供完整的简体中文汉化方案，涵盖 **界面翻译**、**AI 交互中文**、**自动修复失效** 三大功能。

## 📋 目录

- [快速开始](#-快速开始)
- [工作原理](#-工作原理)
- [与其他工具对比](#-与其他工具对比)
- [适用场景与局限性](#-适用场景与局限性)
- [安装指南](#-安装指南)
- [卸载指南](#-卸载指南)
- [常见问题](#-常见问题)
- [更新日志](#-更新日志)
- [问题反馈](#-问题反馈)

---

## 🚀 快速开始

```bash
# 1. 安装汉化（一条命令搞定）
sudo bash claude-zh-CN.sh --install

# 2. 检查汉化状态
bash claude-zh-CN.sh --check

# 3. 卸载汉化（完全清理不留痕迹）
sudo bash claude-zh-CN.sh --uninstall

# 4. Claude 更新后变回英文？一键重装
sudo bash claude-zh-CN.sh --reinstall
```

---

## 🔬 工作原理

Claude Desktop 是基于 Electron + React 开发的桌面应用，汉化需要三层干预：

### 第一层：翻译文件替换（后端 + 前端）
- **后端翻译**：`Resources/zh-CN.json` — 翻译菜单、对话框、设置页等系统界面
- **前端翻译**：`ion-dist/i18n/zh-CN.json` — 翻译聊天界面、侧边栏、功能按钮等 SPA 页面

### 第二层：JS 补丁（绕过语言检测 + 阻止 API 覆盖）
Claude 启动时会检测系统语言，并通过 Anthropic API 获取服务器端的语言设置，这会导致：
1. 系统语言被忽略 → 补丁硬编码 `Hzt="zh-CN"`
2. API 回调覆盖 locale → 补丁阻断 `s?.locale` 的检查逻辑
3. documentElement.lang 未设置 → 补丁强制设为 `"zh-CN"`

### 第三层：系统提示词（AI 交互中文）
在 `~/Library/Application Support/Claude/system_prompt.txt` 中插入系统指令，要求 Claude AI 在所有交互模式（Chat/Cowork/Code）中全程使用简体中文。

### 第四层：开机自动检测（LaunchAgent）
创建 macOS LaunchAgent 守护进程，每次开机 30 秒后自动运行 `autolaunch.sh` 脚本：
- 检测汉化补丁是否失效（通过比对 JS 文件 hash）
- 如果失效，自动重新应用汉化补丁
- 无需用户干预，始终保持汉化状态

---

## ⚖️ 与其他工具对比

| 对比维度 | Claude-Chinese-Toolkit | 其他类似工具（如 WeChatMac-Plugin、Oh My WeChat） |
|----------|----------------------|------------------------------------------------|
| **安装复杂度** | 一行命令 | 通常需手动修改多个配置文件 |
| **版本兼容性** | 自动检测 Claude 版本，动态适配 | 每个 Claude 版本需单独制作补丁 |
| **自动修复** | 开机自动检测 + 修复汉化失效 | 需要手动重新执行 |
| **卸载完整性** | 安装清单系统，反向清理所有痕迹 | 多数工具不提供卸载功能 |
| **AI 交互中文** | 内置 system_prompt.txt，无需额外配置 | 通常需要用户自行配置 |
| **安全性** | 备份原文件，随时可恢复 | 多数工具直接覆盖原始文件 |
| **社区支持** | MIT 协议，完全开源 | 部分工具闭源，存在安全风险 |
| **跨版本兼容** | 支持新旧两种 Claude 架构 | 通常只支持单一版本 |

### 我们的独特优势

1. **三层防护机制**：翻译文件 + JS 补丁 + 系统提示词，确保汉化稳定可靠
2. **自动检测修复**：LaunchAgent 守护进程解决 Claude 更新后汉化失效的核心痛点
3. **无损安装卸载**：所有修改都有备份，卸载后完全恢复原始状态
4. **安装清单追踪**：`~/.claude-zh-inventory` 记录所有安装文件，支持精确清理
5. **Python + Shell 双引擎**：Python 负责复杂的 JS 正则匹配，Shell 负责部署流程，各司其职

---

## 🎯 适用场景与局限性

### 适用场景
- ✅ macOS 用户使用 Claude Desktop 需要中文界面
- ✅ 希望 Claude AI 回复全程使用简体中文
- ✅ 需要自动化维护汉化状态（不想每次更新 Claude 都手动修复）
- ✅ 开发者想要研究 Claude 的 Electron 架构
- ✅ 需要临时汉化（安装清单支持完整卸载）

### 局限性
- ❌ 仅支持 macOS 平台（未支持 Windows/Linux）
- ❌ Claude 移动端（iOS/Android）不适用
- ❌ 翻译覆盖度受限于 Anthropic 官方提供的字符串数量（约 16,000 条，可能有新增字符串未及时翻译）
- ❌ 如果 Anthropic 修改了前端架构（如迁移到 React Native），可能需要重新编写补丁
- ❌ 需要 `sudo` 权限才能安装/卸载
- ❌ 无法汉化 Claude 网页版（仅限 macOS 客户端）

---

## 📥 安装指南

### 方式一：本地脚本安装（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit

# 2. 一键安装
sudo bash claude-zh-CN.sh --install
```

### 方式二：下载 ZIP 包

```bash
# 1. 下载
curl -LO https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/archive/refs/heads/main.zip
unzip main.zip
cd Claude-Chinese-Toolkit-main

# 2. 安装
sudo bash claude-zh-CN.sh --install
```

### 方式三：Homebrew 安装（需配置 Tap）

```bash
brew tap xiaoxianxian/claude-zh
brew install claude-zh
claude-zh --install
```

> **注意**：Homebrew Tap 尚未配置完成，建议使用方式一或方式二。

### 安装后验证

```bash
# 检查汉化状态
bash claude-zh-CN.sh --check
```

预期输出：
```
✓ 汉化状态正常
✓ 后端翻译: zh-CN.json (21140 bytes)
✓ 前端翻译: ion-dist/i18n/zh-CN.json (1001756 bytes)
✓ AI 交互中文: 已启用
✓ 开机自动检测: 配置已存在
```

---

## 🗑️ 卸载指南

### 完全卸载（移除所有汉化痕迹）

```bash
sudo bash claude-zh-CN.sh --uninstall
```

### 仅卸载自动检测（保留汉化）

```bash
sudo bash claude-zh-CN.sh --uninstall-auto
```

### 卸载后验证

```bash
# 检查是否还有汉化痕迹
bash uninstall.sh --check-only
```

---

## 💡 常见问题

### Q1: 安装后 Claude 还是英文？
**A:** 完全退出 Claude（`Cmd + Q`），然后重新打开。汉化文件是持久化修改，重启后即可生效。

### Q2: Claude 更新后变回英文怎么办？
**A:** 运行重装命令：
```bash
sudo bash claude-zh-CN.sh --reinstall
```
如果你的电脑已安装自动检测，它会每 30 秒自动修复一次，无需手动操作。

### Q3: 安装会影响 Claude 的自动更新吗？
**A:** 不会。汉化补丁只修改前端资源文件，不影响 Claude 的内核和更新机制。

### Q4: 如何确认汉化是否正常工作？
**A:** 运行：
```bash
bash claude-zh-CN.sh --check
```
检查所有四项是否为 `✓`。

### Q5: 自动检测什么时候运行？
**A:** 每次开机后 30 秒运行一次。你可以在 `/tmp/claude-zh-autolaunch.log` 查看运行日志。

### Q6: 可以只汉化界面，不安装 AI 交互中文吗？
**A:** 可以：
```bash
sudo bash claude-zh-CN.sh --install --no-ai
```

### Q7: 卸载后能恢复原始文件吗？
**A:** 能。卸载流程会：
1. 如果有 `.bak` 备份，恢复备份文件
2. 如果没有备份，用英文版 `en-US.json` 覆盖中文版
3. 完全清除所有汉化痕迹

### Q8: 安全吗？会被 Anthropic 检测为非法修改吗？
**A:** 我们的方案仅修改前端资源文件（JS/JSON），不侵入应用内核。这与浏览器插件修改页面的原理类似，属于合法的前端定制。

### Q9: 为什么需要 sudo 权限？
**A:** Claude.app 安装在 `/Applications` 目录，该目录受 macOS 系统保护，需要管理员权限才能写入文件。

### Q10: 汉化翻译覆盖了多少百分比？
**A:** 目前已汉化约 16,000+ 条字符串，覆盖界面 95%+ 的内容。剩余少量可能是 Claude 新功能的未翻译字符串。

---

## 📝 更新日志

### v2.6.1 (2026-06-23) - 当前版本

**修复：**
- ✅ N3: 无效参数现在会正确报错并显示帮助信息（之前默认进入安装模式）
- ✅ 修复 `show_help()` 定义顺序问题（满足 `set -u` 严格模式）
- ✅ 修复 Python 代码注入风险（config.json 恢复时使用安全的 `sys.argv` 传参）
- ✅ 修复 `autolaunch.sh` 硬编码路径问题（改为动态搜索 6 个可能位置）
- ✅ 修复 LaunchAgent plist 中的路径拼接方式
- ✅ 修复 `sudo python3 | grep` 管道导致的权限问题
- ✅ 优化日志输出（安装成功后无条件显示"开机自动检测已启用"）

**代码统计：**
```
claude-zh-CN.sh: 546 行 (+110 / -63)
uninstall.sh: 148 行
patch_js.py: 430 行
总计: 1,124 行
```

### v2.6 (2026-06-23)

**重大重构：**
- ✅ 新增一键安装、卸载、重装功能
- ✅ 新增安装清单系统（`~/.claude-zh-inventory`）
- ✅ 修复 LaunchAgent 加载问题（改用 `-c` 内联命令）
- ✅ 新增独立安装/卸载脚本（`install.sh`、`uninstall.sh`）

### v2.5 (2026-06-19)

- ✅ 新增开机自动检测与修复汉化失效功能
- ✅ 新增系统提示词安装（AI 交互中文）

### v2.3.1 (2026-06-18)

- ✅ 修复 Claude 1.14271.0 版本的汉化兼容性问题

---

## 🐛 问题反馈

### 提交 Issue

如果你遇到问题或建议，请在 GitHub Issues 提交：
- 提供 Claude 版本号：`bash claude-zh-CN.sh --check`
- 提供 patch_js.py 的输出日志
- 描述你期望的行为和实际行为

### 联系维护者

- GitHub: https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues
- 邮箱：[你的邮箱，如有]

### 贡献代码

欢迎提交 Pull Request！我们特别需要：
- 新增语言翻译包
- 修复 Claude 新版本兼容性问题
- 改进自动检测脚本的健壮性

---

## 📄 许可证

MIT License — 免费使用，欢迎分享和修改

---

## 🔍 项目结构

```
Claude-Chinese-Toolkit/
├── claude-zh-CN.sh          # 主脚本（安装/卸载/重装/检查）
├── uninstall.sh             # 独立卸载脚本
├── patch_js.py              # Python 汉化补丁引擎
├── install.sh               # 独立安装脚本
├── language-pack/           # 翻译文件目录
│   ├── zh-CN.json           # 前端翻译（16,000+ 条）
│   └── desktop-shell-zh-CN.json  # 后端翻译
├── claude-zh-autolaunch.sh  # 自动检测脚本
├── README.md                # 本文件
└── TEST_PLAN.md             # 测试计划与执行记录
```

---

> **提示**：本工具仅供个人学习和研究用途。请遵守 Claude Desktop 的使用条款和 macOS 的软件许可协议。
