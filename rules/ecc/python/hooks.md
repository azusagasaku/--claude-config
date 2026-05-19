---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Hooks

> 本文件对 [common/hooks.md](../common/hooks.md) 进行扩展，补充 Python 的 hook 配置。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置如下：

- **black/ruff**：编辑 `.py` 文件后自动格式化
- **mypy/pyright**：编辑 `.py` 文件后执行类型检查

## 警告

- 编辑过的文件中若仍存在 `print()` 调用，发出警告。生产项目应使用 `logging` 模块，禁止使用 `print()` 进行日志输出。
