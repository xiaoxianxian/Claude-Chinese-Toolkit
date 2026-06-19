# Homebrew 安装 Claude-Chinese-Toolkit

## 📦 Tap 仓库

- **GitHub 地址**: https://github.com/xiaoxianxian/homebrew-claude-zh
- **Tap 名称**: `xiaoxianxian/claude-zh`
- **Formula**: `claude-zh`

---

## 🚀 安装步骤

### 1. 添加 Tap

```bash
brew tap xiaoxianxian/claude-zh
```

如果之前添加过本地 Tap（指向 `/tmp/...`），先删除再添加：

```bash
# 删除旧 Tap
sudo rm -rf /opt/homebrew/Library/Taps/xiaoxianxian/homebrew-claude-zh/

# 重新添加（从 GitHub）
brew tap xiaoxianxian/claude-zh
```

### 2. 安装

```bash
brew install claude-zh
```

### 3. 运行汉化

```bash
sudo claude-zh
```

### 4. 检查状态（无需 sudo）

```bash
claude-zh --check
```

---

## 🔄 更新

Claude 更新后，重新运行汉化即可：

```bash
brew update
brew upgrade claude-zh
sudo claude-zh
```

---

## 🗑️ 卸载

```bash
brew uninstall claude-zh
sudo rm -f /Applications/Claude.app/Contents/Resources/zh-CN.json
sudo rm -f /Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json
```

---

## ❓ 故障排除

### Q: `brew install claude-zh` 提示 "No available formula"

原因：Tap 指向了旧的本地路径（`/tmp/homebrew-claude-zh/`），但那个目录里当时还没有提交。

解决方法：

```bash
# 1. 删除旧 Tap
sudo rm -rf /opt/homebrew/Library/Taps/xiaoxianxian/homebrew-claude-zh/

# 2. 重新从 GitHub 添加
brew tap xiaoxianxian/claude-zh

# 3. 确认 Formula 存在
ls /opt/homebrew/Library/Taps/xiaoxianxian/homebrew-claude-zh/Formula/
```

### Q: 运行 `sudo claude-zh` 提示 "command not found"

原因：Homebrew 的 `bin` 目录不在 `sudo` 的 `PATH` 里。

解决方法：

```bash
# 查看 claude-zh 的实际路径
which claude-zh
# 输出类似：/opt/homebrew/bin/claude-zh

# 用完整路径运行
sudo /opt/homebrew/bin/claude-zh
```

### Q: 汉化后 Claude 仍是英文

参考主仓库 [README FAQ](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit#-常见问题)

---

## 🔧 手动安装（不通过 Homebrew）

如果不想用 Homebrew，可以直接下载 Release 包：

1. 打开 https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/releases/latest
2. 下载 `Claude-Chinese-Toolkit-v2.3.zip`
3. 解压，在终端运行：
   ```bash
   cd ~/Downloads/Claude-Chinese-Toolkit-v2.3
   bash claude-zh-CN.sh
   ```
4. **Cmd+Q 完全退出 Claude**，重新打开 → 中文界面 ✅

---

## 📝 技术细节

`claude-zh` Formula 做了什么：

1. 下载并安装 `patch_js.py` 到 `$(brew --prefix)/share/claude-zh/`
2. 下载并安装 `language-pack/` 到 `$(brew --prefix)/share/claude-zh/`
3. 创建包装脚本 `/opt/homebrew/bin/claude-zh`
4. 运行 `sudo claude-zh` 时，脚本调用 `patch_js.py` 修改 `/Applications/Claude.app`

Formula 源码：https://github.com/xiaoxianxian/homebrew-claude-zh/blob/main/Formula/claude-zh.rb
