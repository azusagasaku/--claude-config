---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript Hooks

> 本文件对 [common/hooks.md](../common/hooks.md) 进行扩展，补充 TS/JS 的 hook 配置。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置如下：

- **Prettier**：编辑 JS/TS 文件后自动格式化
- **TypeScript 检查**：编辑 `.ts`/`.tsx` 文件后执行 `tsc` 类型检查
- **console.log 警告**：编辑过的文件中若出现 `console.log`，发出警告

## Stop Hooks

- **console.log 审查**：会话结束前扫描所有已修改文件，检查是否残留 `console.log`
