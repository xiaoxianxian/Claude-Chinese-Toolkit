# 🇨🇳 Claude Desktop 简体中文汉化工具

<p align="center">
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest">
    <img src="https://img.shields.io/github/v/release/xiaoxianxian/Claude-Chinese-Toolkit?color=blue&label=最新版本">
  </a>
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit">
    <img src="https://img.shields.io/github/stars/xiaoxianxian/Claude-Chinese-Toolkit?style=social">
  </a>
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/xiaoxianxian/Claude-Chinese-Toolkit">
  </a>
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues">
    <img src="https://img.shields.io/github/issues/xiaoxianxian/Claude-Chinese-Toolkit">
  </a>
</p>

<p align="center">
  <b>一键将 Claude Desktop（macOS）界面汉化为简体中文</b><br>
  自动检测版本 · 支持新版 · 完全开源
</p>

---

## ✨ 效果预览

> 汉化前：`New Chat` `Send` `Settings` `Upgrade`  
> 汉化后：`新建对话` `发送` `设置` `升级`

全界面覆盖：菜单栏、侧边栏、对话框、设置页、快捷键提示……  
约 **16,000 条**界面字符串，覆盖 Claude Desktop 完整界面。

---

## 🚀 快速开始

### 方式一：Homebrew 安装（推荐，支持自动更新）

```bash
# 1. 添加 Tap（首次）
brew tap xiaoxianxian/claude-zh

# 2. 安装
brew install claude-zh

# 3. 运行汉化
sudo claude-zh

# 以后 Claude 更新后，只需：
brew upgrade claude-zh
sudo claude-zh
```

> ⚠️ Homebrew Tap 仓库需先创建（见 [Homebrew 安装说明](HOMEBREW.md)）

### 方式二：下载 Release 包（无需 git）

1. 打开 [Releases 页面](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest)
2. 下载 `Claude-Chinese-Toolkit-v2.3.zip`
3. 解压，在终端运行：
   ```bash
   cd ~/Downloads/Claude-Chinese-Toolkit-v2.3
   bash claude-zh-CN.sh
   ```
4. **Cmd+Q 完全退出 Claude**，重新打开 → 中文界面 ✅

### 方式三：用 Git 克隆

```bash
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

> 📖 完整安装说明（含截图）→ [INSTALL.md](INSTALL.md)

---

## 🔧 工作原理

Claude Desktop 基于 Electron + React，界面语言由三层决定：

| 层面 | 文件 | 作用 |
|------|------|------|
| 系统级 UI | `Resources/zh-CN.json` | 菜单、对话框、系统托盘 |
| 前端 SPA | `ion-dist/i18n/zh-CN.json` | 主界面所有文本（~1MB，~16,000 条） |
| 语言判断 | `ion-dist/assets/v1/index-*.js` | 决定使用哪种语言 |

**核心问题**：Claude 启动时会向服务器请求账号语言设置，如果服务端语言是英文，会**强制把界面重置为英文**，覆盖本地配置。

**解决方案**：修改前端 JS，打补丁：

1. **硬编码初始语言** — 不再从系统/浏览器语言获取，直接固定为 `"zh-CN"`
2. **阻止 API 覆盖** — 服务器返回英文 locale 时，强制改为中文
3. **移除阻断逻辑** — 移除新版 JS 中 `if(!s?.locale)return` 的条件，确保 zh-CN 始终生效
4. **硬编码 documentElement.lang** — 直接设置 `document.documentElement.lang="zh-CN"`，绕过 Hzt 动态初始化

> 💡 **为什么不直接改 config.json？**  
> Claude 每次启动都会从服务端拉取语言设置并覆盖本地配置，改 config.json 无效。必须从源头（JS 层面）拦截。

---

## ⚠️ 已知问题与意外情况

### 情况 1：脚本提示"未找到匹配模式"

Claude 可能发布了新版本，JS 内部结构已变更。脚本会尝试匹配多种模式（旧版 `GTt` 变量、新版 `Hzt` 变量），但如果 Claude 彻底重构了语言初始化逻辑（例如换了变量名、改变了函数结构），补丁就会失效。

**解决方法**：
1. 到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 反馈，附上 JS 文件名
2. 临时方案：手动修改 `patch_js.py`，添加新模式匹配（见下文开发指南）

### 情况 2：Claude 彻底重构 JS 结构

如果 Claude 下次更新时彻底重写了前端代码（例如：换了框架、改了语言初始化流程、使用不同的 i18n 方案），现有补丁可能全部失效。

**如何判断**：
- 运行 `python3 patch_js.py --check`，如果显示多个补丁均未生效
- 运行 `bash claude-zh-CN.sh`，多个补丁显示"未找到匹配模式"

**应对策略**：
- 脚本已内置多版本兼容逻辑，会自动检测 JS 结构变化
- 如遇完全无法识别的新结构，请在 GitHub 提 Issue
- 未来计划：开发自动化测试流程，每次 Claude 更新后自动适配

### 情况 3：Homebrew 安装后 `sudo claude-zh` 找不到命令

Homebrew 安装的 cask 需要 sudo 权限来修改 Claude.app 文件。如果提示 `sudo: claude-zh: command not found`，说明 Homebrew 路径配置有问题。

**解决方法**：
```bash
# 手动运行汉化脚本
sudo python3 /opt/homebrew/share/claude-zh/patch_js.py
```

---

## 📦 适用版本

| 版本 | 状态 | 说明 |
|------|------|------|
| Claude Desktop macOS | ✅ 已测试 | 主要支持平台 |
| v1.12603 及类似旧版 | ✅ 支持 | 自动识别旧版 JS 结构（`kEt` 变量） |
| v2026.06 及类似新版 | ✅ 支持 | 自动识别新版 JS 结构（`GTt` 变量） |
| v1.14271.0+ (2026-06-19) | ✅ 已适配 | 新增 `Hzt` 变量硬编码 + `documentElement.lang` 修复 |
| 未来版本 | 🔄 自动适配 | 脚本自动检测 JS 结构，如遇新版本会提示并跳过 |

> ⚠️ **平台说明**：目前仅完整测试了 **macOS** 版本。Windows 和 Linux 版本的 Claude Desktop 架构可能不同，暂时无法保证兼容。欢迎提交 PR 或 Issue 帮助扩展支持！

---

## 🔄 Claude 更新后怎么办？

Claude 每次自动更新后，JS 文件会被重置为英文版，**界面会变回英文**，这是正常现象。

**解决方法**：重新运行一次脚本即可：
```bash
bash claude-zh-CN.sh
```

脚本会自动检测新版 JS 结构并应用对应补丁，通常 **10 秒内完成**。

> 💡 **未来计划**：正在开发自动版本检测功能，Claude 更新后自动提醒或自动重跑（见 [TODO.md](TODO.md)）。

---

## 🛠 开发指南（应对 Claude 版本变更）

如果你遇到"未找到匹配模式"，可以尝试以下步骤帮助适配：

1. **提供 JS 文件名**：运行 `python3 patch_js.py --check`，记录错误信息中的 JS 文件名（如 `index-CD05FcCU.js`）

2. **查看初始化逻辑**：在终端执行：
   ```bash
   grep -oE '.{100}Hzt=.100' \
     "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/你的JS文件名.js"
   ```

3. **修改 `patch_js.py`**：在 `patch_js()` 函数中添加新的匹配模式：
   ```python
   # 补丁 1: 硬编码初始 locale
   # 添加新的匹配模式
   new_pattern = '你的新匹配模式'
   new_replacement = '你的替换值'
   if new_pattern in content:
       content = content.replace(new_pattern, new_replacement)
   ```

4. **反馈给作者**：到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 提交问题，附上：
   - Claude 版本号（`/Applications/Claude.app/Contents/Info.plist` 中的 `CFBundleShortVersionString`）
   - JS 文件名
   - 上述命令的输出

---

## 📁 文件结构

```
Claude-Chinese-Toolkit/
├── INSTALL.md                # 详细安装说明（新手必读）
├── README.md                 # 本文件
├── claude-zh-CN.sh         # 一键汉化脚本（bash 入口）
├── patch_js.py              # JS 补丁脚本（自动检测版本）
├── TRANSLATION_STATUS.md    # 翻译进度追踪（社区贡献入口）
├── CONTRIBUTING.md          # 贡献指南（如何参与翻译/开发）
└── language-pack/           # 中文翻译文件
    ├── zh-CN.json                 # 前端翻译（~1MB，~16,000 条）
    ├── desktop-shell-zh-CN.json   # 后端/桌面端翻译
    ├── Localizable.strings        # macOS 本地化字符串
    └── zh-CN.overrides.json     # 翻译覆盖规则
```

---

## ❓ 常见问题

<details>
<summary><b>Q: Claude 更新后变回英文了？</b></summary>

完全退出 Claude（Cmd+Q），重新运行：
```bash
bash claude-zh-CN.sh
```
脚本会自动识别新版本并应用补丁。
</details>

<details>
<summary><b>Q: 如何还原/卸载？</b></summary>

脚本运行时自动创建备份（`backups/` 目录）。还原方法：

```bash
# 1. 找到备份文件（ls backups/ 查看）
# 2. 还原 JS 文件（文件名以 index- 开头）
sudo cp backups/index-XXXXXX.js.YYYYMMDD_HHMMSS \
  "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/index-XXXXXX.js"

# 3. 删除中文翻译
sudo rm "/Applications/Claude.app/Contents/Resources/zh-CN.json"
sudo rm "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json"

# 4. 重启 Claude
```
</details>

<details>
<summary><b>Q: 脚本提示"未找到匹配模式"？</b></summary>

Claude 可能发布了新版本，JS 内部结构已变更。请到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 反馈，附上错误信息。
</details>

<details>
<summary><b>Q: 对 Claude 功能有影响吗？</b></summary>

无。所有修改仅涉及界面文字和语言判断逻辑，不影响 AI 模型能力和任何功能。
</details>

<details>
<summary><b>Q: 翻译不完整/有错误？</b></summary>

翻译文件基于 Claude 官方英文界面提取，部分新版本新增字符串可能暂无翻译。  
欢迎提交 PR 完善翻译！参见 [CONTRIBUTING.md](CONTRIBUTING.md)。
</details>

---

## 🤝 参与贡献

Claude-Chinese-Toolkit 欢迎社区贡献！

- 🐛 **报告问题**：遇到 bug 或新版本不兼容？[提 Issue](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues)
- 🌍 **贡献翻译**：帮助完善中文翻译，或添加其他语言！参见 [CONTRIBUTING.md](CONTRIBUTING.md)
- 💻 **贡献代码**：改进脚本、添加新功能、支持更多平台
- ⭐ **Star 支持**：在 GitHub 上给个 Star，让更多人看到

---

## 📝 注意事项

- ⚠️ 运行前确保 Claude **完全退出**（Cmd+Q，而不仅仅是关闭窗口）
- ⚠️ 每次 Claude 版本更新后需重新执行一次
- ⚠️ 目前仅完整测试了 **macOS** 版本（Windows/Linux 欢迎贡献支持）
- ⚠️ 本工具修改 Claude.app 内部文件，自行承担使用风险

---

## 📄 许可

MIT License. 翻译内容版权归原作者所有。

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/xiaoxianxian">xiaoxianxian</a>
  ·
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit">GitHub</a>
  ·
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues">问题反馈</a>
</p>
