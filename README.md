# Claude Desktop 简体中文汉化工具包

[![GitHub Release](https://img.shields.io/github/v/release/xiaoxianxian/Claude-Chinese-Toolkit?color=blue)](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest)

一键将 Claude Desktop（macOS）界面汉化为简体中文。  
支持多版本自动检测，Claude 更新后重新运行即可。

## 下载方式

**推荐：下载 GitHub Release（无需 git）**

→ [点击下载最新版 ZIP](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest)

解压后直接运行 `bash claude-zh-CN.sh` 即可。

## 快速开始

**方式一：下载 Release 包（无需 git，推荐）**

1. 打开 [Releases 页面](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest)
2. 下载 `Claude-Chinese-Toolkit-v2.2.zip`
3. 解压，在终端中运行：
   ```bash
   cd ~/Downloads/Claude-Chinese-Toolkit-v2.2
   bash claude-zh-CN.sh
   ```
4. 完全退出 Claude（**Cmd+Q**）后重新打开，界面即为中文

**方式二：用 Git 克隆**

```bash
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

> 📖 完整安装说明详见 [INSTALL.md](INSTALL.md)

## 适用版本

- **Claude Desktop for macOS**（Electron 架构）
- **已测试**: v1.12603.1（旧版变量 `kEt/NS`）、v2026.06（新版变量 `GTt/PS`）
- **自动检测**: 脚本会自动识别 JS 结构版本，应用对应补丁
- Claude 每次更新后需重新运行一次

## 工作原理

Claude Desktop 基于 Electron + React，界面语言由三个层面决定：

| 层面 | 文件 | 作用 |
|------|------|------|
| 系统级 UI | `Resources/zh-CN.json` | 菜单、对话框、系统托盘 |
| 前端 SPA | `ion-dist/i18n/zh-CN.json` | 主界面所有文本（~1MB） |
| 语言判断 | `ion-dist/assets/v1/index-*.js` | 决定使用哪种语言 |

**核心问题**：Claude 启动时会向服务器请求账号语言设置，如果服务端语言是英文，会强制把界面重置为英文，覆盖本地配置。

**解决方案**：修改前端 JS，打两个补丁：

1. **硬编码初始语言** — 不再从系统/浏览器语言获取，直接固定为 `"zh-CN"`
2. **阻止 API 覆盖** — 服务器返回英文 locale 时，强制改为中文

## 文件结构

```
Claude-Chinese-Toolkit/
├── INSTALL.md               # 安装说明（新手必读）
├── README.md                # 本文件
├── claude-zh-CN.sh        # 一键汉化脚本（bash 入口）
├── patch_js.py              # JS 补丁脚本（自动检测版本）
└── language-pack/          # 中文翻译文件
    ├── zh-CN.json                 # 前端翻译（~1MB）
    ├── desktop-shell-zh-CN.json  # 后端/桌面端翻译
    ├── Localizable.strings        # macOS 本地化字符串
    └── zh-CN.overrides.json    # 覆盖配置
```

## 脚本执行流程

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 安装翻译文件 | 复制中文翻译到 Claude.app 资源目录 |
| 2 | JS 补丁 | 自动检测版本，应用对应补丁 |
| 3 | 修改配置 | 将 `config.json` 中 locale 设为 `zh-CN` |
| - | 自动备份 | 原版文件备份到 `backups/` 目录 |

## 常见问题

### Q: Claude 更新后变回英文了？
完全退出 Claude（Cmd+Q），重新运行 `bash claude-zh-CN.sh` 即可。

### Q: 如何还原/卸载？
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

### Q: 脚本提示"未找到匹配模式"？
Claude 可能发布了新版本，JS 内部结构已变更。请到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 反馈，附上错误信息。

### Q: config.json 修改失败？
如果脚本提示权限不足，请手动修改：
1. 打开 `~/Library/Application Support/Claude/config.json`
2. 将 `"locale": "en-US"` 改为 `"locale": "zh-CN"`
3. 保存并重新打开 Claude

### Q: 对 Claude 功能有影响吗？
无。所有修改仅涉及界面文字和语言判断逻辑，不影响 AI 模型能力和任何功能。

### Q: 翻译不完整/有错误？
翻译文件基于 Claude 官方英文界面提取，部分新版本新增字符串可能暂无翻译。欢迎提交 PR 完善翻译。

## 注意事项

- ⚠️ 运行前确保 Claude **完全退出**（Cmd+Q，而不仅仅是关闭窗口）
- ⚠️ 每次 Claude 版本更新后需重新执行一次
- ⚠️ 仅适用于 macOS 版本
- ⚠️ 本工具修改 Claude.app 内部文件，自行承担使用风险

## 许可

MIT License. 翻译内容版权归原作者所有。
