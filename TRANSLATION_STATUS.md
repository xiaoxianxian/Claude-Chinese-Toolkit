# 翻译状态追踪

> 本文档追踪 Claude Desktop 中文翻译的完成度，方便社区贡献者找到需要翻译的字符串。

---

## 📊 总体状态

| 项目 | 数值 |
|------|------|
| 翻译基于版本 | Claude Desktop v1.13576.4 |
| 前端翻译条数 | ~16,000 条 |
| 后端翻译条数 | ~425 条 |
| 预计覆盖率 | ~95% |
| 最后更新 | 2026-06-18 |

---

## 🔍 如何检查缺失的翻译

运行以下命令，自动对比英文原文和中文翻译：

```bash
python3 check_translation_status.py
```

这会生成 `translation-status/report.md`，列出所有缺失的翻译 key。

---

## 📝 已知缺失/待完善的翻译

### 前端翻译（ion-dist/i18n/zh-CN.json）

以下类型的字符串可能在新版本中缺失：

| 版本 | 可能缺失的区域 | 状态 |
|------|----------------|------|
| v1.13576+ | 设置页新增 AI Mmodel 选项 | 🔄 待确认 |
| v1.13576+ | 侧边栏右键菜单新选项 | 🔄 待确认 |
| 未来版本 | 每次更新后新增的字符串 | 🔄 需手动检查 |

### 后端翻译（Resources/zh-CN.json）

后端翻译基于 Electron 主进程，相对稳定。已知可能缺失：

- 新版本新增的菜单项
- 新版本新增的对话框文本

---

## 🌍 如何贡献翻译

### 方式一：报告缺失的翻译

如果你发现界面上有英文未翻译：

1. **截图**：截下包含未翻译英文的界面区域
2. **提 Issue**：到 [GitHub Issues](https://github.com/xiaoxianxian/Claude-Chinese-Toolkit/issues) 新建 Issue
3. **注明位置**：说明这个字符串出现在哪个界面、哪个按钮/菜单

### 方式二：直接提交翻译 PR

如果你知道如何修改翻译文件：

1. **找到英文原文**：
   ```bash
   # 在 Claude.app 中找到英文 key
   grep -r "未翻译的英文" /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json
   ```

2. **添加中文翻译**：
   编辑 `language-pack/zh-CN.json`，添加对应的中文翻译：
   ```json
   "对应的 key": "中文翻译"
   ```

3. **测试**：运行 `bash claude-zh-CN.sh` 应用翻译，重启 Claude 查看效果

4. **提交 PR**：
   ```bash
   git checkout -b fix/translation-missing-keys
   git add language-pack/zh-CN.json
   git commit -m "翻译: 添加 XXX 区域缺失的翻译"
   git push origin fix/translation-missing-keys
   ```
   然后在 GitHub 上创建 Pull Request

---

## 🔧 翻译文件格式说明

### 前端翻译（zh-CN.json）

格式：JSON 对象，key 为 Claude 内部字符串 ID，value 为中文翻译。

```json
{
  "chat.newChat": "新建对话",
  "chat.send": "发送",
  "settings.title": "设置"
}
```

### 后端翻译（desktop-shell-zh-CN.json）

格式：JSON 对象，key 为 Electron 主进程字符串 key。

```json
{
  "menu.file": "文件",
  "menu.edit": "编辑",
  "dialog.confirm": "确认"
}
```

---

## 📋 翻译规范

如果你要贡献翻译，请遵循以下规范：

1. **界面用语**：使用符合中文用户习惯的界面用语（如"新建"而非"创建"，"对话框"而非"弹窗"）
2. **简洁明了**：翻译后的字符串长度尽量接近原文，避免界面布局问题
3. **专业术语**：AI 相关术语保持一致性（如 "prompt" → "提示词"，"token" → "令牌"）
4. **保留格式**：保留原文中的 `\n`、`%s` 等格式符号

---

## 🔄 更新翻译（维护者指南）

当 Claude 发布新版本后，更新翻译的步骤：

1. **提取英文原文**：
   ```bash
   cp /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json \
      language-pack/en-US-latest.json
   ```

2. **对比差异**：
   ```bash
   python3 check_translation_status.py
   ```

3. **手动翻译新增 key**：参照 `translation-status/missing-keys.json`

4. **测试**：应用翻译，检查界面显示是否正常

5. **提交更新**：
   ```bash
   git add language-pack/zh-CN.json
   git commit -m "翻译: 同步 Claude vX.X.X 新增字符串"
   git push origin main
   ```

---

## 💡 未来计划

- [ ] 自动化翻译检查（CI 中自动运行 `check_translation_status.py`）
- [ ] 支持更多语言（繁体中文、日文、韩文等）
- [ ] 众包翻译平台（类似 Crowdin）
- [ ] 翻译记忆库（避免重复翻译）

---

<p align="right">
  <i>最后更新：2026-06-18</i>
</p>
