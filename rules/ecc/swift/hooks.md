---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift 钩子

> 本文件基于 [common/hooks.md](../common/hooks.md) 扩展，补充了 Swift 特有内容。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **SwiftFormat**：编辑 `.swift` 文件后自动格式化
- **SwiftLint**：编辑 `.swift` 文件后执行 lint 检查
- **swift build**：编辑后对修改的包进行类型检查

## 警告

检测到 `print()` 时应标记——生产代码应替换为 `os.Logger` 或其他结构化日志方案。
