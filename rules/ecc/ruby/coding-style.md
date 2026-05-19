---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
  - "**/*.gemspec"
  - "**/config.ru"
---
# Ruby 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 Ruby 和 Rails 特定的编码约定。

## 标准

- 新建 Rails 项目应使用 **Ruby 3.3+**，除非项目已锁定在较旧但仍在支持期内的版本。
- **YJIT** 不应默认启用；应先通过启动时间、内存和请求/任务吞吐量指标进行基准测试后决定。
- 若项目使用 `# frozen_string_literal: true` 约定，新 Ruby 文件应添加此声明。
- 编写 Ruby 代码应追求清晰可读，避免不必要的元编程复杂性；DSL 较多的代码应隔离在范围小、有测试保护的边界后。

## 格式化与代码检查

- 使用项目内签入的 RuboCop 配置。Rails 8+ 应用从 `rubocop-rails-omakase` 起步，仅当代码库确有自定义约定时才调整。
- 格式化/检查命令放入 binstubs 或脚本中，本地和 CI 保持一致：

```bash
bundle exec rubocop
bundle exec rubocop -A
```

- 不应使用内联注释屏蔽检查规则，除非该例外情况范围明确、有文档记录，且无法通过代码清晰表达。

## Rails 风格

- 优先遵循 Rails 的命名和目录约定，不足时再添加自定义结构。
- 控制器仅处理传输层：身份验证、授权、参数处理、响应格式。
- 可复用的业务行为放入模型、concern、服务对象、查询对象、表单对象，按实际复杂度决定，而非作为形式化模板。
- 使用 `bin/rails`、`bin/rake` 和签入的 binstubs，避免使用全局安装的命令。

## 错误处理

- 捕获具体的异常类型，避免广泛的 `rescue StandardError` 块，除非会重新抛出或为运维提供充分上下文。
- 运维事件使用 `ActiveSupport::Notifications` 或应用日志记录器记录；不应在已提交代码中保留 `puts`、`pp`、`debugger` 等调试语句。

## 参考

服务/仓库分层更多指导参见技能：`backend-patterns`。
