# 贡献指南

感谢你考虑为 **Claude-Chinese-Toolkit** 做出贡献！🙏

---

## 🐛 报告问题

遇到 bug、新版本不兼容、翻译错误？请到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 提 Issue。

**报告时请附上**：
- Claude Desktop 版本号（`菜单 → 关于 Claude`）
- macOS 版本
- 错误信息截图或终端输出
- 复现步骤

---

## 🌍 贡献翻译

### 方式一：报告缺失的翻译

1. 截图包含未翻译英文的界面
2. 到 [Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 新建 Issue
3. 注明字符串出现在哪个界面、哪个按钮/菜单

### 方式二：直接修改翻译文件

#### 1. 找到英文原文 key

```bash
# 在 Claude.app 中搜索英文文本对应的 key
grep -r "Send" /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json | head -5
```

#### 2. 添加中文翻译

编辑 `language-pack/zh-CN.json`，添加对应的中文翻译：

```json
{
  "chat.send": "发送",
  "settings.title": "设置"
}
```

#### 3. 测试翻译效果

```bash
# 应用翻译
bash claude-zh-CN.sh

# 完全退出 Claude（Cmd+Q）后重新打开
# 检查翻译是否生效
```

#### 4. 提交 PR

```bash
git checkout -b fix/translation-missing-keys
git add language-pack/zh-CN.json
git commit -m "翻译: 添加 XXX 区域缺失的翻译"
git push origin fix/translation-missing-keys
```

然后在 GitHub 上创建 Pull Request。

---

## 💻 贡献代码

### 开发流程

1. **Fork 仓库** 到你的 GitHub 账号
2. **创建分支**：`git checkout -b feature/your-feature`
3. **修改代码**
4. **测试**：确保在 macOS 上能正常运行
5. **提交**：`git commit -m "feat: 描述你的改动"`
6. **推送**：`git push origin feature/your-feature`
7. **创建 PR**

### 代码规范

- **Shell 脚本**：使用 `bash` 语法，添加注释
- **Python 脚本**：遵循 PEP 8，添加 docstring
- **提交信息**：使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式

### 测试检查清单

- [ ] 脚本在 macOS 上能正常运行
- [ ] 处理了 Claude 未安装的情况
- [ ] 处理了 Claude 正在运行的情况
- [ ] 添加了错误处理
- [ ] 更新了相关文档（README.md 等）

---

## 📝 Pull Request 指南

### PR 标题格式

```
<type>: <description>

# 例如：
feat: 支持 Claude v1.14.x 新版 JS 结构
fix: 修复 --check 模式在 macOS 14 上崩溃
docs: 更新 INSTALL.md 添加截图说明
translation: 添加设置页缺失的翻译
```

### Type 说明

| Type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `translation` | 翻译更新 |
| `refactor` | 代码重构 |
| `test` | 测试相关 |
| `chore` | 构建/工具链更新 |

### PR 描述模板

```markdown
## 改动说明
<!-- 描述你的改动 -->

## 相关 Issue
<!-- 如果有，填写 Fixes #123 -->

## 测试步骤
1. 
2. 

## 截图（如果有 UI 变化）
```

---

## 🌟 其他贡献方式

- ⭐ **Star 仓库**：让更多人看到这个项目
- 📣 **分享**：分享给需要中文汉化的朋友
- 💡 **建议**：在 Issues 中提出改进建议
- 📖 **文档**：改进 README、INSTALL.md 等文档

---

## 📄 许可证

贡献的代码将遵循 MIT License。提交 PR 即表示你同意你的贡献可以在 MIT License 下使用。

---

再次感谢你的贡献！🙏
