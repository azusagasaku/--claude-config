---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
  - "**/*.psgi"
  - "**/*.cgi"
---
# Perl 钩子系统

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 Perl 特定的钩子配置。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **perltidy**：编辑后自动格式化 `.pl` 和 `.pm` 文件。
- **perlcritic**：编辑 `.pm` 文件后执行代码检查。

## 警告

- 非脚本的 `.pm` 文件中使用 `print` 时应提醒 —— 应使用 `say` 或日志模块（如 `Log::Any`）。
