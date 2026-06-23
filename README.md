# 🇨🇳 Claude Desktop 简体中文汉化工具 — 完整使用手册

<p align="center">
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest">
    <img src="https://img.shields.io/github/v/release/xiaoxianxian/Claude-Chinese-Toolkit?color=blue&label=最新版本">
  </a>
  <a href="https://github.com/xiaoxianxian/Claude-Chinese-Toolkit">
    <img src="https://img.shields.io/github/stars/xiaoxianxian/Claude-Chinese-Toolkit?style=social">
  </a>
</p>

---

## 📋 目录

1. [解决的问题](#1-解决的问题)
2. [工作原理](#2-工作原理)
3. [与其他方案的比较](#3-与其他方案的比较)
4. [安装方式](#4-安装方式)
5. [使用指南](#5-使用指南)
6. [卸载/还原](#6-卸载还原)
7. [常见问题](#7-常见问题)
8. [技术细节](#8-技术细节)

---

## 1. 解决的问题

### 1.1 问题背景

Claude Desktop 官方目前**不提供简体中文界面**。即使你的 macOS 系统是中文，Claude 也会显示英文界面。这是因为：

1. **服务端语言覆盖** — Claude 启动时会向 Anthropic 服务器请求账号语言设置，如果账号语言是英文，服务器会返回 `en-US`，**强制将界面重置为英文**。
2. **config.json 无效** — 传统的修改 `config.json` 中 `locale` 字段的方法已被证明**无效**，因为 Claude 每次启动都会从服务端拉取语言设置并覆盖本地配置。
3. **每次更新后失效** — Claude 版本更新后会替换前端 JS 文件，之前的汉化补丁失效，界面变回英文。

### 1.2 我们解决了什么

本工具一次性解决三个层面的问题：

| 层面 | 问题 | 解决方案 |
|------|------|----------|
| **界面文字** | 菜单、按钮、对话框等界面元素全是英文 | 注入 16,000+ 条中文翻译 |
| **语言判断** | Claude 强制使用英文 locale | 修改 JS 文件，硬编码 zh-CN |
| **AI 交互** | AI 回应全是英文，不符合中文习惯 | 写入系统提示词，强制 AI 使用中文 |

---

## 2. 工作原理

### 2.1 界面汉化原理

Claude Desktop 基于 Electron + React 构建，界面语言由三层决定：

```
┌─────────────────────────────────────────────────────┐
│  第一层：系统级 UI                                     │
│  文件: Resources/zh-CN.json                          │
│  作用: 菜单、对话框、系统托盘等 Electron 原生 UI       │
├─────────────────────────────────────────────────────┤
│  第二层：前端 SPA                                     │
│  文件: ion-dist/i18n/zh-CN.json                      │
│  作用: 主界面所有文本（~1MB，~16,000 条字符串）        │
├─────────────────────────────────────────────────────┤
│  第三层：语言判断                                     │
│  文件: ion-dist/assets/v1/index-*.js                 │
│  作用: 决定使用哪种语言                               │
└─────────────────────────────────────────────────────┘
```

**补丁过程：**

1. **注入翻译文件** — 复制中文翻译文件到 `Resources/` 和 `ion-dist/i18n/`
2. **硬编码初始语言** — 修改 JS 中语言初始化代码，不再从系统/浏览器语言获取
3. **阻止 API 覆盖** — 拦截服务器返回的英文 locale，强制改为中文
4. **移除阻断逻辑** — 新版 JS 中有 `if(!s?.locale)return` 的条件，会导致 zh-CN 设置被跳过，补丁会移除这个条件

### 2.2 AI 交互中文原理

Claude Desktop 支持 `system_prompt.txt` 配置文件（位于 `~/Library/Application Support/Claude/`），该文件中的指令会在所有交互模式中生效：

- **Chat 模式** — 日常对话、提问回答
- **Cowork 模式** — 协同工作、文件编辑
- **Code 模式** — 代码生成、调试、审查

系统提示词会告诉 Claude "始终使用简体中文交流"，这会覆盖默认的英文交互。

---

## 3. 与其他方案的比较

### 3.1 主流方案对比

| 方案 | 原理 | 优点 | 缺点 |
|------|------|------|------|
| **本工具（JS 补丁）** | 直接修改 Claude.app 内部 JS 文件 | ✅ 效果稳定<br>✅ 不受服务端控制<br>✅ 覆盖完整界面 | ⚠️ 每次 Claude 更新需重新打补丁<br>⚠️ 需要 sudo 权限<br>⚠️ 非官方修改 |
| **修改 config.json** | 修改 `~/Library/Application Support/Claude/config.json` | ✅ 操作简单 | ❌ 已被证明**完全无效**（服务端覆盖） |
| **修改系统语言** | 将 macOS 系统语言设为中文 | ✅ 简单 | ❌ 影响所有应用<br>❌ 不适用于不想切换系统的用户<br>❌ Claude 仍会显示英文 |
| **第三方客户端** | 使用其他 GUI 封装 | ✅ 可能有中文 | ❌ 功能可能落后<br>❌ 安全性未知<br>❌ 失去官方功能更新 |
| **API + 自行封装** | 使用 Claude API + 自建前端 | ✅ 完全可控 | ❌ 技术门槛高<br>❌ 需要 API Key<br>❌ 维护成本高 |

### 3.2 本方案的独特优势

1. **从源头解决** — 在 JS 层面硬编码 zh-CN，服务器返回的英文 locale 会被拦截
2. **版本自适应** — 脚本自动检测不同版本的 JS 结构，支持新旧两种补丁逻辑
3. **双重保障** — 既注入翻译文件，又硬编码语言，即使其中一层失效仍有保障
4. **安全透明** — 开源脚本，每一步都可审计，不会悄悄修改不该修改的地方
5. **一键复原** — 自动备份原始文件，随时可还原

### 3.3 已知局限

1. **需要重新打补丁** — 每次 Claude 版本更新后，JS 文件被替换，需重新运行脚本（约 10 秒）
2. **仅支持 macOS** — 目前仅完整测试 macOS 版本，Windows/Linux 暂不支持
3. **翻译可能滞后** — 新功能上线后，翻译文件可能缺少新字符串的中文翻译

---

## 4. 安装方式

### 方式一：Homebrew 安装（推荐）

```bash
# 1. 添加 Tap（首次）
brew tap xiaoxianxian/claude-zh

# 2. 安装
brew install claude-zh

# 3. 运行汉化
sudo claude-zh
```

以后 Claude 更新后，只需：
```bash
brew upgrade claude-zh
sudo claude-zh
```

### 方式二：下载 Release 包

1. 打开 [Releases 页面](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest)
2. 下载 `Claude-Chinese-Toolkit-v2.4.zip`
3. 解压，在终端运行：
   ```bash
   cd ~/Downloads/Claude-Chinese-Toolkit-v2.4
   bash claude-zh-CN.sh
   ```

### 方式三：用 Git 克隆

```bash
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

---

## 5. 使用指南

### 5.1 首次使用

1. **完全退出 Claude** — 如果 Claude 正在运行，先 Cmd+Q 完全退出
2. **运行脚本** — 按上述任一方式安装后，运行汉化脚本
3. **按提示选择** — 脚本会提示是否安装 AI 中文交互提示词和开机自动汉化（推荐选 1）
4. **重新打开 Claude** — 此时界面应为简体中文，AI 交互也为中文

### 5.2 开机自动汉化

**v2.5 新增：开机自动检测与修复汉化失效**

安装完成后，系统会自动注册一个开机启动项（LaunchAgent），工作流程：

```
开机 → 等待 30 秒 → 检测汉化状态 → 如果失效则自动修复 → 完成
```

**特点：**
- ✅ 零配置：安装后自动启用，无需手动设置
- ✅ 智能检测：仅在汉化失效时才重新打补丁（节省时间）
- ✅ 静默运行：后台执行，不影响正常开机
- ✅ 日志可查：`/tmp/claude-zh-autolaunch.log`

**如何停用自动汉化：**
```bash
bash claude-zh-CN.sh --uninstall-auto
```

> ⚠️ **注意**：Claude 版本更新后，JS 文件可能被替换。如果自动检测未生效，可手动运行 `bash claude-zh-CN.sh` 重新汉化。

### 5.2 Claude 更新后/重启后

**重要说明：** 汉化补丁**不会**随系统启动自动运行。每次以下情况时需重新运行：

1. **每次开机后打开 Claude** — 如果之前汉化未生效，运行一次脚本
2. **每次 Claude 自动更新** — JS 文件被替换，汉化失效
3. **每次检测到"需要重新汉化"** — 运行 `python3 patch_js.py --check`

**快速修复：**
```bash
# 检查汉化状态
python3 patch_js.py --check

# 重新汉化（约 10 秒完成）
bash claude-zh-CN.sh
```

> 💡 **未来计划**：正在开发自动检测功能，在开机或 Claude 更新后自动提醒或自动重跑。

### 5.3 检查汉化状态

```bash
python3 patch_js.py --check
```

输出示例：
```
── 汉化状态 ─────────────────────────────────────────
  Claude 版本:  1.14271.0
  JS 文件:      index-CD05FcCU.js
  上次汉化:    2026-06-19 12:37:34

✓ 汉化状态正常
```

如果显示"需要重新汉化"，请运行完整脚本重新打补丁。

### 5.4 仅汉化界面（不需要 AI 中文）

```bash
bash claude-zh-CN.sh --no-system
```

这会跳过系统提示词的安装，仅汉化界面文字。

---

## 6. 卸载/还原

### 6.1 完整卸载

```bash
# 1. 还原 JS 文件（使用备份）
sudo cp backups/index-XXXXXX.js.YYYYMMDD_HHMMSS \
  "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/index-XXXXXX.js"

# 2. 删除中文翻译
sudo rm "/Applications/Claude.app/Contents/Resources/zh-CN.json"
sudo rm "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json"

# 3. 删除系统提示词
rm ~/Library/Application\ Support/Claude/system_prompt.txt

# 4. 重启 Claude
```

### 6.2 仅禁用 AI 中文交互

```bash
rm ~/Library/Application\ Support/Claude/system_prompt.txt
```

### 6.3 Homebrew 卸载

```bash
brew uninstall claude-zh
```

---

## 7. 常见问题

### Q: 如何确认汉化成功了？

运行 `python3 patch_js.py --check`，如果显示"✓ 汉化状态正常"，说明汉化生效。

### Q: Claude 更新后每次都手动运行脚本吗？

目前是的。未来计划开发自动检测功能，在 Claude 更新后自动提醒或自动重跑。

### Q: 汉化会影响 Claude 的功能吗？

不会。所有修改仅涉及界面文字和语言判断逻辑，不影响 AI 模型能力和任何功能。

### Q: 翻译不完整/有错误？

翻译文件基于 Claude 官方英文界面提取，部分新版本新增字符串可能暂无翻译。欢迎提交 PR 完善翻译！参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

### Q: 脚本提示"未找到匹配模式"？

Claude 可能发布了新版本，JS 内部结构已变更。请到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 反馈，附上 JS 文件名。

### Q: Homebrew 安装后 `sudo claude-zh` 找不到命令？

Homebrew 安装的 cask 需要 sudo 权限来修改 Claude.app 文件。如果提示 `sudo: claude-zh: command not found`，请手动运行：

```bash
sudo python3 /opt/homebrew/share/claude-zh/patch_js.py
```

---

## 8. 技术细节

### 8.1 支持的 Claude 版本

| 版本 | 状态 | 说明 |
|------|------|------|
| v1.12603 及类似旧版 | ✅ 支持 | 自动识别旧版 JS 结构（`kEt` 变量） |
| v2026.06 及类似新版 | ✅ 支持 | 自动识别新版 JS 结构（`GTt` 变量） |
| v1.14271.0+ (2026-06-19) | ✅ 已适配 | 新增 `Hzt` 变量硬编码 + `documentElement.lang` 修复 |
| 未来版本 | 🔄 自动适配 | 脚本自动检测 JS 结构，如遇新版本会提示并跳过 |

### 8.2 已知局限

1. **首次需手动运行** — 首次安装汉化后，需手动运行一次脚本。之后每次开机自动检测修复。Claude 版本更新后可能需额外运行一次。
2. **仅支持 macOS** — 目前仅完整测试 macOS 版本，Windows/Linux 暂不支持。
3. **翻译可能滞后** — 新功能上线后，翻译文件可能缺少新字符串的中文翻译。
4. **自动检测频率** — 当前仅在开机后检测一次（30 秒后），如需更频繁检测可自行设置 cron 任务。

### 8.2 已知局限

1. **不会自动启动** — 汉化补丁不是开机自启程序，每次开机后需重新运行脚本（约 10 秒）。Claude 每次更新后 JS 文件被替换，也必须重新运行脚本。
2. **仅支持 macOS** — 目前仅完整测试 macOS 版本，Windows/Linux 暂不支持。
3. **翻译可能滞后** — 新功能上线后，翻译文件可能缺少新字符串的中文翻译。

### 8.3 平台说明

目前仅完整测试了 **macOS** 版本。Windows 和 Linux 版本的 Claude Desktop 架构可能不同，暂时无法保证兼容。

### 8.4 注意事项

- ⚠️ 运行前确保 Claude **完全退出**（Cmd+Q，而不仅仅是关闭窗口）
- ⚠️ 每次 Claude 版本更新后需重新执行一次
- ⚠️ 本工具修改 Claude.app 内部文件，自行承担使用风险

---

## 🤝 参与贡献

Claude-Chinese-Toolkit 欢迎社区贡献！

- 🐛 **报告问题**：遇到 bug 或新版本不兼容？[提 Issue](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues)
- 🌍 **贡献翻译**：帮助完善中文翻译，或添加其他语言！参见 [CONTRIBUTING.md](CONTRIBUTING.md)
- 💻 **贡献代码**：改进脚本、添加新功能、支持更多平台
- ⭐ **Star 支持**：在 GitHub 上给个 Star，让更多人看到

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
