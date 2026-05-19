---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
  - "**/Gemfile.lock"
  - "**/config/routes.rb"
---
# Ruby 钩子系统

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 Ruby 和 Rails 特定的钩子配置。

## PostToolUse 钩子

配置项目本地的钩子，优先使用 binstubs 和签入的工具：

- **RuboCop**：编辑 Ruby 文件后执行 `bundle exec rubocop -A <file>` 或项目中更安全的格式化命令。
- **Brakeman**：涉及安全的 Rails 改动后执行 `bundle exec brakeman --no-progress`。
- **测试**：针对被修改文件运行最匹配的 `bin/rails test ...` 或 `bundle exec rspec ...` 命令。
- **Bundler 审计**：`Gemfile` 或 `Gemfile.lock` 有变动且项目安装了 bundler-audit 时，执行 `bundle exec bundle-audit check --update`。

## 警告

- 应用代码中若存在已提交的 `debugger`、`binding.irb`、`binding.pry`、`puts`、`pp` 或 `p` 调用，发出提醒。
- 编辑操作关闭了 CSRF 防护、扩大了批量赋值范围、或添加了未参数化的原始 SQL，应提醒。
- 迁移操作以破坏性方式修改数据，且无可逆路径或文档化上线计划，应提醒。

## CI 关卡建议

```bash
bundle exec rubocop
bundle exec brakeman --no-progress
bin/rails test
bundle exec rspec
```

仅使用项目中已配置的命令；未经维护者同意不应安装新的钩子依赖。
