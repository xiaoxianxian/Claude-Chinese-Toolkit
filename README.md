# Claude Desktop 简体中文汉化工具

一键将 Claude Desktop (macOS) 界面汉化为简体中文。

## 快速开始

```bash
# 1. 下载本仓库
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit

# 2. 确保 Claude 已关闭，然后执行
bash claude-zh-CN.sh

# 3. 重新打开 Claude
```

## 适用版本

- Claude Desktop for macOS (Electron 架构)
- 已测试: v1.12603.1+
- 每次 Claude 更新后需重新运行

## 原理说明

Claude Desktop 基于 Electron + React，界面语言由三个层面决定：

| 层面 | 文件位置 | 作用 |
|------|---------|------|
| 系统级 UI | `Resources/zh-CN.json` | 菜单、对话框、系统托盘 |
| 前端 SPA | `ion-dist/i18n/zh-CN.json` | 主界面所有文本（1MB/16325条） |
| 语言判断 | `ion-dist/assets/v1/index-*.js` | 决定使用哪种语言 |

**核心问题**：Claude 启动时会向服务器请求语言设置，如果账号语言是英文，会把界面强制重置为英文，覆盖本地配置。

**解决方案**：修改前端 JS 中的两个关键变量：

1. **`kEt`** — 初始语言变量，硬编码为 `"zh-CN"` 而不是从系统获取
2. **`jEt`** 函数 — 从 API 获取语言的回调，强制把 `"en-US"` 改为 `"zh-CN"`

## 文件结构

```
Claude-Chinese-Toolkit/
├── claude-zh-CN.sh          # 一键汉化脚本
├── README.md                # 本文件
└── language-pack/
    ├── zh-CN.json           # 前端翻译（1MB，16325条）
    ├── desktop-shell-zh-CN.json  # 后端翻译（21KB，425条）
    ├── Localizable.strings  # macOS 本地化字符串
    └── zh-CN.overrides.json # 覆盖配置
```

## 脚本做了什么

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 创建备份 | 备份原版 JS 文件、en-US.json、config.json |
| 2 | 安装翻译 | 将中文翻译文件复制到 Claude.app 内 |
| 3 | 修改 JS | 打两个关键补丁（硬编码 kEt + 强制覆盖 jEt） |
| 4 | 修改配置 | 将 config.json 中 locale 设为 zh-CN |

## 常见问题

### Q: Claude 更新后变回英文了？
运行一次 `bash claude-zh-CN.sh` 即可恢复。

### Q: 可以卸载/还原吗？
脚本运行时自动创建了备份（`backups/` 目录）。如需还原：
```bash
# 还原 JS 文件（路径按实际备份文件名）
cp backups/index-BQutSDqp.js.XXXXXXXX.txt \
   "/Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/index-BQutSDqp.js"

# 还原 config.json
cp backups/config.json.XXXXXXXX \
   "$HOME/Library/Application Support/Claude/config.json"
```

### Q: config.json 修改失败？
如果脚本提示权限不足，请手动修改：
1. 打开 `~/Library/Application Support/Claude/config.json`
2. 将 `"locale": "en-US"` 改为 `"locale": "zh-CN"`
3. 保存并重新打开 Claude

### Q: 对 Claude 功能有影响吗？
无。所有翻译均为界面文字，不影响 AI 模型能力和功能。

## 注意事项

- ⚠️ 运行前确保 Claude 完全退出（Cmd + Q，不是关闭窗口）
- ⚠️ 每次 Claude 版本更新后需重新执行
- ⚠️ 仅适用于 macOS 版本
- ⚠️ 如 Claude JS 文件名变化（如 `index-BQutSDqp.js` 改名），需更新脚本中的路径

## 许可

MIT License. 翻译内容版权归原作者所有。
