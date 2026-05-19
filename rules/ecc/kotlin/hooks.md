---
paths:
  - "**/*.kt"
  - "**/*.kts"
  - "**/build.gradle.kts"
---
# Kotlin 钩子

> 本文件基于 [common/hooks.md](../common/hooks.md) 扩展，补充了 Kotlin 特有内容。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **ktfmt/ktlint**：编辑 `.kt` 和 `.kts` 文件后自动格式化
- **detekt**：编辑 Kotlin 文件后自动执行静态分析
- **./gradlew build**：编辑后编译验证
