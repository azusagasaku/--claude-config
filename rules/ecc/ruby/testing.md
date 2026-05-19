---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
  - "**/test/**/*.rb"
  - "**/spec/**/*.rb"
  - "**/config/routes.rb"
---
# Ruby 测试

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 Ruby 和 Rails 特定的测试实践。

## 测试框架

- Rails 应用使用默认测试栈时选用 **Minitest**。
- 项目中已建立 RSpec 规范或有明确团队约定时选用 **RSpec**。
- 除非有迁移计划，否则避免在同一功能区域内混用 Minitest 和 RSpec。

## 测试金字塔

- 快速的业务行为测试放入模型、服务、查询、策略和任务测试中。
- 请求/控制器测试验证 HTTP 约定、认证行为、重定向、状态码和响应格式。
- 仅浏览器关键流程使用 Capybara 编写系统测试；测试应保持专注，避免不稳定。
- 后台任务：单元测试验证行为，集成测试验证队列/入队约定。

## 固定数据与工厂

- 数据图不大且项目默认使用 Rails fixtures 时，可继续使用。
- 场景需要明确对象构造或复杂特征组合时使用 `factory_bot`。
- 测试数据应贴近所断言的行为；不应使用全局 fixtures 隐藏数据准备逻辑。

## 命令

优先使用项目本地命令：

```bash
bin/rails test
bin/rails test test/models/user_test.rb
bundle exec rspec
bundle exec rspec spec/models/user_spec.rb
```

## 覆盖率

- 使用 SimpleCov 强制执行覆盖率；在 CI 中设置阈值，避免为满足分支覆盖率编写低价值测试。
- 修改生产代码前应先为 bug 修复编写回归测试。

## 参考

全仓库 RED -> GREEN -> REFACTOR 循环参见技能：`tdd-workflow`。
