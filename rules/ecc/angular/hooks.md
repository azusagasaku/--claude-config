---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.service.ts"
  - "**/*.directive.ts"
  - "**/*.pipe.ts"
  - "**/*.spec.ts"
---
# Angular 钩子

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 Angular 特定的钩子配置。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **Prettier**：编辑后自动格式化 `.ts` 和 `.html` 文件
- **ESLint / ng lint**：编辑 Angular 源文件后执行 `ng lint`，可检测装饰器误用、模板错误和样式违规
- **TypeScript 检查**：编辑 `.ts` 文件后执行 `tsc --noEmit`
- **构建检查**：生成或大规模修改 Angular 代码后执行 `ng build`，尽早捕获模板和类型错误

## Stop 钩子

- **Lint 审计**：会话结束前对已修改文件执行 `ng lint`，识别未处理的违规项
