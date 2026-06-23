# Claude-Chinese-Toolkit v2.6 功能清单 + 测试用例

## 一、功能清单

### 正向功能（Positive Cases）

| 编号 | 功能 | 预期行为 | 测试命令 |
|------|------|---------|---------|
| F1 | 帮助信息展示 | `--help` 显示所有可用命令和说明 | `bash claude-zh-CN.sh --help` |
| F2 | 汉化状态检测 | `--check` 显示汉化补丁、翻译文件、system_prompt、LaunchAgent 状态 | `bash claude-zh-CN.sh --check` |
| F3 | 一键安装（完整版） | 安装翻译文件 + 汉化补丁 + system_prompt.txt + LaunchAgent | `sudo bash claude-zh-CN.sh --install` |
| F4 | 一键安装（仅界面） | 安装翻译文件 + 汉化补丁，不安装 system_prompt.txt | `sudo bash claude-zh-CN.sh --install --no-ai` |
| F5 | 一键重装 | 先卸载再安装（Claude 更新后恢复） | `sudo bash claude-zh-CN.sh --reinstall` |
| F6 | 一键卸载（全部清理） | 移除 LaunchAgent + 恢复翻译文件 + 恢复 JS 备份 + 移除 system_prompt.txt + 清理配置 | `sudo bash claude-zh-CN.sh --uninstall` |
| F7 | 仅卸载自动检测 | 移除 LaunchAgent 但不影响汉化 | `sudo bash claude-zh-CN.sh --uninstall-auto` |
| F8 | 翻译文件安装 | zh-CN.json 复制到后端和资源目录 | 安装时自动执行 |
| F9 | 汉化补丁应用 | patch_js.py 自动检测版本并应用 JS 补丁 | 安装时自动执行 |
| F10 | system_prompt.txt 安装 | 创建 AI 交互中文指令文件 | 安装时自动执行 |
| F11 | LaunchAgent 安装 | 创建 com.claude-zh-CN.auto-launch.plist 并尝试加载 | 安装时自动执行 |
| F12 | Claude 自动退出 | 安装前检测 Claude 进程并退出 | 安装时自动执行 |
| F13 | Claude 版本检测 | 读取 CFBundleShortVersionString | 安装时自动执行 |
| F14 | 独立 uninstall.sh | 可从任意目录运行的一键卸载脚本 | `bash uninstall.sh` |
| F15 | 独立 uninstall.sh --check-only | 仅检查汉化痕迹，不删除 | `bash uninstall.sh --check-only` |

### 负向功能（Negative Cases）

| 编号 | 场景 | 预期行为 | 测试方式 |
|------|------|---------|---------|
| N1 | 未安装 Claude.app | 安装脚本应报错并提示 | 模拟缺少 Claude.app |
| N2 | 翻译文件目录不存在 | 安装脚本应报错 | 模拟缺少 language-pack/ |
| N3 | 无效参数 | 显示错误信息 + 帮助信息并退出 | 传入未知参数 |
| N4 | 无 sudo 权限 | 安装/卸载失败并提示权限不足 | 非 sudo 执行 |
| N5 | Claude 无法退出 | 安装中断并提示手动退出 | 模拟 Claude 进程不可终止 |
| N6 | 文件权限不足 | 写入失败并给出明确错误提示 | 模拟目录只读 |
| N7 | 重复安装 | 不应破坏已有安装，应覆盖更新 | 连续运行两次 install |
| N8 | 无备份文件卸载 | 应有降级策略（用英文版覆盖） | 模拟 .bak 不存在 |
| N9 | JS 文件不存在 | patch_js.py 应报错 | 模拟缺失 JS bundle |
| N10 | config.json 损坏 | Python JSON 解析应捕获异常 | 模拟损坏的 JSON |

## 二、边界场景测试

| 编号 | 场景 | 预期行为 |
|------|------|---------|
| B1 | Claude 已汉化后重装 | 应识别已有备份，跳过备份步骤 |
| B2 | 多次执行 uninstall | 第二次执行应提示无汉化痕迹 |
| B3 | LaunchAgent plist 损坏 | 应能重新创建 |
| B4 | 空 system_prompt.txt | 应覆盖而非合并 |
| B5 | Python3 未安装 | 应给出明确错误提示 |

## 三、测试执行记录

### 第 1 轮测试（2026-06-19）
测试顺序：F1→F2→F3→F4→F6→N1→N3→B1→B2

| 编号 | 结果 | 备注 |
|------|------|------|
| F1 | ✓ PASS | --help 显示正确 |
| F2 | ✓ PASS | --check 显示完整信息 |
| F3 | ⚠ 待测试 | sudo 密码问题需真实环境测试 |
| F4 | ✗ 待测试 | |
| F6 | ✗ 待测试 | |
| N1 | ✗ 待测试 | |
| N3 | ⚠ PARTIAL | --invalid-arg 默认进入安装模式，非帮助信息 |
| B1 | ✗ 待测试 | |
| B2 | ✗ 待测试 | |

### 第 2 轮测试（2026-06-23 - 验证已安装状态）
| 编号 | 结果 | 备注 |
|------|------|------|
| F8 | ✓ PASS | 后端翻译: 21140 bytes |
| F9 | ✓ PASS | JS 汉化补丁已应用 (Hzt="zh-CN") |
| F10 | ✓ PASS | system_prompt.txt 已创建 (1080 bytes) |
| F11 | ✓ PASS | LaunchAgent 已安装 (691 bytes) |
| F14 | ✓ PASS | uninstall.sh --check-only 正常工作 |
| F15 | ✓ PASS | --check-only 列出了所有汉化痕迹 |

### 第 3 轮测试 - 代码审查和修复（2026-06-23）

本轮重点进行了完整的代码审查和修复工作。

#### 代码审查发现的问题和修复
| 问题 | 严重性 | 修复方案 | 状态 |
|------|--------|---------|------|
| N3: 无效参数未报错退出 | 高 | 修改参数解析逻辑，遇到未知参数报错+显示帮助并 exit 1 | ✓ 已修复 |
| show_help() 在参数解析后被定义 | 高 | 将 show_help() 移到参数解析之前，满足 set -u 要求 | ✓ 已修复 |
| autolaunch.sh 硬编码项目路径 | 中 | 改为动态搜索多个可能的安装位置 | ✓ 已修复 |
| LaunchAgent plist 中路径拼接不当 | 中 | 使用变量 ${AUTOLAUNCH_SCRIPT_PATH} 避免硬编码 | ✓ 已修复 |
| do_install() 中 sudo python3 管道问题 | 低 | 改用 if/then 结构正确处理 sudo 错误 | ✓ 已修复 |
| 安装成功后缺少 "开机自动检测已启用" 日志 | 低 | 无条件输出该日志行 | ✓ 已修复 |
| config.json 恢复时的 Python 注入风险 | 中 | 改用 HEREDOC 变量方式传递 Python 代码，避免 shell 变量注入 | ✓ 已修复 |
| install_auto_launch() 条件判断冗余 | 低 | 移除 `$INSTALL_AUTO == false` 的条件判断 | ✓ 已修复 |

#### 已验证的测试
| 测试项 | 结果 | 说明 |
|--------|------|------|
| F1 | ✓ PASS | --help 正常输出帮助 |
| F2 | ✓ PASS | --check 正常输出状态 |
| N3 | ✓ PASS | --invalid-param 报错+帮助并 exit 1 |
| 语法检查 | ✓ PASS | bash -n claude-zh-CN.sh 通过 |
| 语法检查 | ✓ PASS | bash -n uninstall.sh 通过 |
| 语法检查 | ✓ PASS | python3 patch_js.py 通过 |
| 总代码行数 | 546/148/430 | claude-zh-CN.sh / uninstall.sh / patch_js.py |

### 待测试项（需要真实终端环境 + sudo 权限）
| 编号 | 场景 | 备注 |
|------|------|------|
| F4 | --no-ai 选项 | 仅汉化界面 |
| F5 | --reinstall 重装 | 需要 sudo |
| F6 | --uninstall 卸载 | 需要 rm/launchctl 权限 |
| F7 | --uninstall-auto | 需要 sudo |
| N1 | 未安装 Claude.app | 需要模拟环境 |
| N4 | 无 sudo 权限 | 非 sudo 执行 |
| N7 | 重复安装 | 连续运行两次 install |
| N8 | 无备份卸载 | 模拟 .bak 不存在 |
| B1 | 汉化后重装 | 应识别已有备份 |
| B2 | 多次卸载 | 第二次应提示无痕迹 |
