# 🎉 Claude Desktop 中文终极体验方案 v2.5

## 📋 概述

本方案是一套**完整的 Claude Desktop 中文解决方案**，解决三个层面的问题：

1. **界面汉化** — 16,000+ 条中文字符串覆盖完整界面
2. **AI 交互中文** — 所有模式（Chat/Cowork/Code）全程中文交流
3. **自动检测修复** — 每次开机自动检测并修复汉化失效

## 🎯 解决的核心问题

### 为什么需要这个方案？

Claude Desktop 官方不提供简体中文支持，且有以下特殊机制：

1. **服务端语言覆盖** — Claude 启动时会从 Anthropic 服务器获取语言设置
2. **强制英文重置** — 如果账号语言是英文，会覆盖本地配置，强制重置为英文
3. **每次更新失效** — Claude 自动更新会替换 JS 文件，汉化被清空

## 🔧 工作原理

### 界面汉化（三层保护）

```
┌─────────────────────────────────────────┐
│  1. 注入翻译文件                         │
│     - Resources/zh-CN.json (菜单/对话框) │
│     - ion-dist/i18n/zh-CN.json (SPA界面)│
├─────────────────────────────────────────┤
│  2. 硬编码初始语言                       │
│     修改 JS 初始化逻辑，固定为 zh-CN    │
├─────────────────────────────────────────┤
│  3. 阻止 API 覆盖                       │
│     拦截服务器返回的 en-US，强制改为 zh-CN│
└─────────────────────────────────────────┘
```

### AI 交互中文

在 `system_prompt.txt` 写入指令，告诉 Claude "始终使用简体中文交流"，覆盖默认英文交互。

### 自动检测修复（v2.5 新增）

开机后 30 秒自动运行 `patch_js.py --check`，检测汉化状态，如果失效则自动修复。

## 📥 安装方式

### 方式一：Homebrew（推荐）

```bash
brew tap xiaoxianxian/claude-zh
brew install claude-zh
sudo claude-zh
```

### 方式二：下载 Release 包

```bash
curl -L https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest/download/Claude-Chinese-Toolkit-v2.5.zip -o /tmp/claude-zh.zip
unzip /tmp/claude-zh.zip -d /tmp/claude-zh
cd /tmp/claude-zh
bash claude-zh-CN.sh
```

### 方式三：Git 克隆

```bash
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

## 🚀 使用流程

### 首次使用

1. 完全退出 Claude（Cmd+Q）
2. 运行汉化脚本
3. 按提示选择（推荐选 1，启用全部功能）
4. 重新打开 Claude

### 开机自动运行

- 安装后自动注册 LaunchAgent
- 每次开机后 30 秒自动检测并修复汉化
- 仅当检测到失效时才重新打补丁（节省时间）
- 日志：`/tmp/claude-zh-autolaunch.log`

### 手动检查

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

如果显示"需要重新汉化"，请运行：
```bash
bash claude-zh-CN.sh
```

### 快速修复

如果 Claude 更新后汉化失效：
```bash
# 方法 1: 运行脚本
bash claude-zh-CN.sh

# 方法 2: 直接运行 patch
python3 patch_js.py

# 方法 3: 一键修复（如果自动检测未生效）
sudo python3 patch_js.py
```

## 🛠 卸载与还原

### 卸载自动检测

```bash
bash claude-zh-CN.sh --uninstall-auto
```

### 完整卸载

```bash
# 1. 删除系统提示词
rm ~/Library/Application\ Support/Claude/system_prompt.txt

# 2. 删除汉化配置
sudo rm "/Applications/Claude.app/Contents/Resources/zh-CN.json"
sudo rm "/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json"

# 3. 卸载 Homebrew（如果使用）
brew uninstall claude-zh
```

## ⚠️ 注意事项

### 已知局限

1. **首次需手动运行** — 首次安装后需手动运行脚本，之后自动检测
2. **Claude 更新可能失效** — 如果自动检测未生效，手动运行一次脚本即可
3. **仅支持 macOS** — Windows/Linux 暂不支持
4. **翻译可能滞后** — 新功能上线后可能需要等待翻译更新

### 性能影响

- **内存占用**：几乎为零（仅在系统级缓存翻译文件）
- **启动延迟**：几乎无影响（自动检测仅在开机后运行一次）
- **系统负载**：极低（仅在特定时刻检测，不常驻后台）

### 安全性

- **开源审计**：所有代码公开，可随时审查
- **最小权限**：仅需 sudo 修改 Claude.app 内部文件
- **备份机制**：每次修改前自动备份原始文件
- **可逆操作**：随时可还原到原始状态

## 📊 与其他方案对比

| 特性 | 本方案 | 修改 config.json | 第三方客户端 | 自建 API |
|------|--------|-----------------|-------------|----------|
| 效果稳定性 | ✅ 高 | ❌ 无效 | ✅ 中 | ✅ 高 |
| 维护成本 | ✅ 低 | ✅ 低 | ✅ 低 | ❌ 高 |
| 功能完整性 | ✅ 完整 | ✅ 部分 | ✅ 部分 | ✅ 完整 |
| 安全性 | ✅ 可审计 | ✅ 低风险 | ❌ 未知 | ✅ 可控 |
| 自动更新 | ✅ 支持 | ✅ 支持 | ✅ 支持 | ✅ 支持 |
| 跨平台 | ❌ macOS only | ✅ 跨平台 | ✅ 跨平台 | ✅ 跨平台 |

## 🏗 技术架构

```
┌─────────────────────────────────────────────────────┐
│  Claude Desktop 中文解决方案                          │
├─────────────────────────────────────────────────────┤
│  界面层：                                            │
│    ├─ zh-CN.json (桌面端翻译)                        │
│    ├─ i18n/zh-CN.json (前端翻译)                     │
│    └─ index-*.js (语言判断修改)                      │
├─────────────────────────────────────────────────────┤
│  交互层：                                            │
│    └─ system_prompt.txt (AI 交互指令)                │
├─────────────────────────────────────────────────────┤
│  自动层：                                            │
│    ├─ LaunchAgent (开机自动检测)                     │
│    └─ patch_js.py (补丁应用脚本)                     │
└─────────────────────────────────────────────────────┘
```

## 🔄 更新日志

### v2.5 (2026-06-23)

- ✨ 新增开机自动检测与修复功能
- ✨ 新增 `--uninstall-auto` 卸载自动检测
- 🐛 修复多次出现的重复内容问题
- 📝 更新文档，简化使用流程

### v2.4 (2026-06-22)

- ✨ 新增 AI 交互中文提示词功能
- ✨ 支持 Chat/Cowork/Code 模式全程中文
- 📝 更新 README，添加使用说明

### v2.3 (2026-06-19)

- 🐛 修复 Claude 1.14271.0 版本汉化失效问题
- ✨ 新增 Hzt 变量硬编码补丁
- ✨ 新增 documentElement.lang 硬编码
- ✨ 移除 Bzt 函数中的阻断条件

## 📝 许可证

MIT License. 翻译内容版权归原作者所有。

---

Made with ❤️ by [xiaoxianxian](https://github.com/xiaoxianxian)
· [GitHub](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit)
· [问题反馈](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues)
