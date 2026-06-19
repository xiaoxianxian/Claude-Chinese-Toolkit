# Homebrew 安装说明

> 通过 Homebrew 安装 Claude-Chinese-Toolkit，支持一键安装和未来自动更新。

---

## 📦 安装步骤

### 1. 设置 Homebrew Tap（首次）

Claude-Chinese-Toolkit 需要自己的 Homebrew Tap 仓库。

**方式 A：使用已创建的 Tap（推荐）**

如果 Tap 仓库 `xiaoxianxian/homebrew-claude-zh` 已创建：

```bash
brew tap xiaoxianxian/claude-zh
```

**方式 B：手动创建 Tap 仓库**

如果 Tap 仓库尚未创建，需要先在 GitHub 上创建：

1. 在 GitHub 上创建新仓库，名称为：`homebrew-claude-zh`
2. 仓库名必须以 `homebrew-` 开头
3. 设为 Public
4. 然后在本地 clone 并添加 Formula：

```bash
# Clone Tap 仓库
git clone https://github.com/xiaoxianxian/homebrew-claude-zh.git
cd homebrew-claude-zh

# 复制 Formula 文件
cp /path/to/Claude-Chinese-Toolkit/claude-zh.rb .

# 提交并推送
git add claude-zh.rb
git commit -m "Add claude-zh formula"
git push origin main

# 添加 Tap
brew tap xiaoxianxian/claude-zh
```

---

### 2. 安装

```bash
brew install claude-zh
```

---

### 3. 使用

```bash
# 完整运行（推荐）
sudo claude-zh

# 检查是否需要重新汉化
claude-zh --check
```

---

### 4. 更新

Claude 更新后，界面会变回英文。重新运行汉化：

```bash
# 更新工具本身
brew upgrade claude-zh

# 重新应用汉化
sudo claude-zh
```

---

## 🔧 手动测试 Formula

如果你想在提交前测试 Formula：

```bash
# 从本地文件安装（不提交到 Tap）
brew install --build-from-source ./claude-zh.rb

# 测试
sudo claude-zh --check

# 卸载
brew uninstall claude-zh
```

---

## 📝 Formula 更新流程

当 Claude-Chinese-Toolkit 发布新版本后，更新 Formula：

1. **下载新版本的 tarball**：
   ```bash
   # 在本 repo 打 tag 后，GitHub 会自动创建 tarball
   # URL 格式：https://github.com/USER/REPO/archive/refs/tags/vX.Y.Z.tar.gz
   ```

2. **计算 SHA256**：
   ```bash
   curl -L -o /tmp/claude-zh.tar.gz "https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/archive/refs/tags/v2.3.tar.gz"
   shasum -a 256 /tmp/claude-zh.tar.gz
   ```

3. **更新 `claude-zh.rb`**：
   - 修改 `url` 中的版本号
   - 替换 `sha256` 为实际值

4. **提交到 Tap 仓库**：
   ```bash
   cd homebrew-claude-zh
   git add claude-zh.rb
   git commit -m "Update claude-zh to v2.3"
   git push origin main
   ```

5. **用户更新**：
   ```bash
   brew update
   brew upgrade claude-zh
   ```

---

## ❓ 常见问题

<details>
<summary><b>Q: brew tap 失败？</b></summary>

确保 Tap 仓库存在且公开。如果尚未创建，按照「方式 B」手动创建。
</details>

<details>
<summary><b>Q: 安装后运行提示找不到 Python？</b></summary>

确保已安装 Python 3：
```bash
brew install python@3.9
```
</details>

<details>
<summary><b>Q: 如何卸载？</b></summary>

```bash
brew uninstall claude-zh
```
注意：卸载工具不会自动移除已应用的汉化。如需还原，参见 [INSTALL.md](INSTALL.md) 的「如何还原」章节。
</details>

---

## 🔗 相关链接

- [Claude-Chinese-Toolkit 主仓库](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit)
- [Homebrew 官方文档](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
