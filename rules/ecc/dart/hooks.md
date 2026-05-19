---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/analysis_options.yaml"
---
# Dart/Flutter 钩子

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 Dart 和 Flutter 特定的钩子配置。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **dart format**：编辑后自动格式化 `.dart` 文件
- **dart analyze**：编辑 Dart 文件后执行静态分析，检测警告
- **flutter test**：大规模修改后可选择性运行受影响的测试

## 推荐的钩子配置

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Edit", "file_paths": ["**/*.dart"] },
        "hooks": [
          { "type": "command", "command": "dart format $CLAUDE_FILE_PATHS" }
        ]
      }
    ]
  }
}
```

## 提交前检查

提交 Dart/Flutter 更改前执行以下命令：

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
flutter test
```

## 实用单行命令

```bash
# 格式化所有 Dart 文件
dart format .

# 分析并报告问题
dart analyze

# 运行所有测试并生成覆盖率
flutter test --coverage

# 重新生成代码生成文件
dart run build_runner build --delete-conflicting-outputs

# 检查过时的包
flutter pub outdated

# 在约束范围内升级包
flutter pub upgrade
```
