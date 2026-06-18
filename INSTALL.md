# 安装说明

## 一键安装（推荐）

**适用系统：** macOS（Claude Desktop）

### 步骤一：下载工具包

**方式 A：用 Git 下载（推荐）**
```bash
git clone https://github.com/xiaoxianxian/Claude-Chinese-Toolkit.git
cd Claude-Chinese-Toolkit
```

**方式 B：直接下载 ZIP**
1. 打开 https://github.com/xiaoxianxian/Claude-Chinese-Toolkit
2. 点击绿色的 **Code** 按钮 → **Download ZIP**
3. 解压下载的 ZIP 文件

---

### 步骤二：运行汉化脚本

打开**终端**（Terminal），执行：

```bash
cd /path/to/Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

> 💡 把 `/path/to` 换成你实际解压的路径，比如：
> `cd ~/Downloads/Claude-Chinese-Toolkit`

脚本会自动：
1. 检测你的 Claude 版本（新旧版都能处理）
2. 备份原始文件（存在 `backups/` 目录）
3. 复制中文翻译文件
4. 修改前端 JS，锁定界面语言为中文

看到 `✅ 汉化完成！` 就成功了。

---

### 步骤三：重启 Claude

完全退出 Claude（**Cmd+Q**，不是只是关闭窗口），然后重新打开。

界面应该已经是中文了 🎉

---

## 常见问题

### Q：运行脚本时报权限错误？
**A：** 脚本需要修改 `/Applications/Claude.app` 里的文件，如果提示 `Permission denied`，用 `sudo` 运行：
```bash
sudo bash claude-zh-CN.sh
```

### Q：Claude 更新后又变回英文了？
**A：** Claude 自动更新后 JS 文件名会变，重新运行一次脚本就好：
```bash
cd /path/to/Claude-Chinese-Toolkit
bash claude-zh-CN.sh
```

### Q：想恢复英文界面？
**A：** 脚本会自动备份原始文件，恢复方法：
```bash
# 查看备份文件
ls /path/to/Claude-Chinese-Toolkit/backups/

# 手动恢复（把 .bak 文件复制回原处，或重新安装 Claude）
```

最简单的方法：重新安装 Claude Desktop，会自动恢复原始文件。

### Q：支持 Windows 吗？
**A：** 目前只支持 macOS 版 Claude Desktop。Windows 版原理类似，但需要不同的脚本。

### Q：脚本安全吗？
**A：** 脚本只做三件事：
1. 备份原始文件
2. 复制翻译文件（JSON）
3. 修改前端 JS 中的 locale 变量（硬编码为 `zh-CN`）

不会收集任何数据，不会访问网络。源码完全开放，可以自己审查。

---

## 工作原理（技术向）

Claude Desktop 基于 Electron 构建，有两层翻译机制：
- **后端翻译：** `/Applications/Claude.app/Contents/Resources/zh-CN.json`
- **前端翻译：** `/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json`

根本问题：Claude 启动时会从 API 获取 locale 并覆盖本地设置，导致界面恢复英文。

解决方案：修改前端 JS，硬编码 `locale = "zh-CN"` 并阻止 API 覆盖。

---

## 文件说明

```
Claude-Chinese-Toolkit/
├── claude-zh-CN.sh        # 一键汉化脚本（入口）
├── patch_js.py             # JS 补丁脚本（自动调用）
├── language-pack/          # 中文翻译文件
│   ├── zh-CN.json                 # 前端翻译（~1MB，16000+ 条）
│   ├── desktop-shell-zh-CN.json  # 后端翻译（~21KB，420+ 条）
│   ├── Localizable.strings       # macOS 本地化字符串
│   └── zh-CN.overrides.json    # 翻译覆盖规则
├── backups/                # 自动备份目录（运行脚本后生成）
└── README.md              # 项目说明
```

---

## 反馈与贡献

- **Bug 反馈：** https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues
- **Pull Request：** 欢迎提交改进！

---

## 免责声明

本工具仅供学习交流使用，修改第三方软件可能产生风险，请自行备份数据。作者不对使用本工具导致的任何问题负责。
