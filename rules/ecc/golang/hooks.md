---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go Hooks

> 本文件对 [common/hooks.md](../common/hooks.md) 进行扩展，补充 Go 的 hook 配置。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置如下：

- **gofmt/goimports**：编辑 `.go` 文件后自动格式化
- **go vet**：编辑 `.go` 文件后执行静态分析
- **staticcheck**：对已修改的包执行更全面的静态检查
