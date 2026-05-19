---
paths:
  - "**/*.php"
  - "**/composer.json"
  - "**/phpstan.neon"
  - "**/phpstan.neon.dist"
  - "**/psalm.xml"
---
# PHP 钩子系统

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 PHP 特定的钩子配置。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **Pint / PHP-CS-Fixer**：编辑 `.php` 文件后自动格式化。
- **PHPStan / Psalm**：在有类型标注的代码库中编辑 PHP 文件后执行静态分析。
- **PHPUnit / Pest**：涉及行为变更时，针对所修改文件或模块运行针对性测试。

## 警告

- 编辑文件后检查是否残留 `var_dump`、`dd`、`dump` 或 `die()` 调用，如有则发出提醒。
- 编辑的 PHP 文件若新增了原始 SQL 拼接或禁用了 CSRF/会话保护，应发出提醒。
