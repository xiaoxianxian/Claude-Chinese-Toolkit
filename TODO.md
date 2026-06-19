# TODO - Claude-Chinese-Toolkit

> 本文档追踪未来改进计划。欢迎提交 PR 实现这些功能！

---

## 🔥 高优先级

- [ ] **自动检测 Claude 更新并提醒**
  - 实现 LaunchAgent，在用户登录时自动运行 `patch_js.py --check`
  - 如果需要重新汉化，弹出通知提醒用户
  - 相关文件：`patch_js.py`（已有 `--check` 标志）

- [ ] **支持 Windows 版本**
  - Claude Desktop for Windows 的架构可能不同
  - 需要找到 Windows 版的翻译文件路径和 JS bundle 位置
  - 相关：README 中已注明"目前仅测试了 macOS"

- [ ] **支持 Linux 版本**
  - Claude Desktop for Linux（如果有）的适配

---

## 🔧 中优先级

- [ ] **翻译状态 CI 检查**
  - 在 GitHub Actions 中自动运行 `check_translation_status.py`
  - 当翻译覆盖率低于阈值时，自动创建 Issue 提醒

- [ ] **Homebrew Tap 完善**
  - 创建 `homebrew-claude-zh` 仓库
  - 完善 `claude-zh.rb` Formula（修复 Ruby 语法）
  - 测试 `brew install claude-zh` 完整流程

- [ ] **自动翻译新增字符串**
  - 当 Claude 更新后，自动用 AI 翻译新增的英文字符串
  - 需要调用翻译 API（DeepL / Google Translate / AI API）

- [ ] **备份管理**
  - 目前的备份文件（`backups/` 目录）会累积
  - 实现自动清理旧备份（保留最近 3 个）

---

## 🔵 低优先级

- [ ] **支持更多语言**
  - 繁体中文（香港、台湾）
  - 日文
  - 韩文

- [ ] **翻译记忆库**
  - 避免重复翻译相同的字符串
  - 导出/导入翻译记忆（TMX 格式）

- [ ] **图形界面（GUI）**
  - 目前的脚本是命令行界面
  - 可以做一个简单的 Swift UI 界面，让不熟悉终端的用户也能使用

- [ ] **Claude 内嵌更新检测**
  - 目前需要用户手动重新运行脚本
  - 可以做一个后台守护进程，监控 `/Applications/Claude.app` 的变更

---

## 🐛 已知问题

- [ ] **`patch_js.py` 补丁2 硬编码了 `PS` 函数名**
  - 目前 `const n=PS(["zh-CN"])` 中的 `PS` 是硬编码的
  - 如果 Claude 未来版本中规范化函数不叫 `PS`，补丁2 会失效
  - 改进：动态检测规范化函数名

- [ ] **翻译文件可能不完整**
  - 目前翻译基于某个特定版本的 Claude
  - 未来版本新增的字符串可能没有翻译
  - 改进：每次 Claude 更新后，自动对比 `en-US.json` 并提示更新翻译

---

## 📋 发布 Checklist

### 发布新版本前

- [ ] 更新 `README.md` 中的版本号和下载链接
- [ ] 打 Git tag（`git tag vX.Y.Z`）
- [ ] 推送 tag（`git push origin --tags`）
- [ ] 在 GitHub 上创建 Release，附上 Release 包
- [ ] 更新 `claude-zh.rb` Formula 中的 URL 和 SHA256
- [ ] 推送 Formula 更新到 Tap 仓库

---

## 💡 想法箱

- **插件系统**：让社区可以提交翻译插件（类似 VS Code 语言包）
- **A/B 测试**：测试不同的翻译风格（正式 vs 口语化）
- **翻译质量评分**：让用户可以给翻译打分，收集反馈改进

---

<p align="right">
  <i>最后更新：2026-06-18</i>
</p>
