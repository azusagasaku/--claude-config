---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
  - "**/app/**/*.erb"
  - "**/config/routes.rb"
---
# Ruby 模式

> 本文件扩展了 [common/patterns.md](../common/patterns.md)，补充 Ruby 和 Rails 特定的设计模式。

## 优先采用 Rails 约定

- 中小功能直接使用原生 Rails MVC 和 Active Record 约定，不应过早引入额外抽象。
- 当模型/控制器边界的职责过于复杂时，再引入服务对象、查询对象、表单对象、装饰器或展示器。
- 提取的对象按业务操作命名，避免使用 `Manager`（管理器）或 `Processor`（处理器）等模糊名称。

## 持久化

- 多主机生产环境 Rails 应用优先使用 PostgreSQL，除非现有平台有明确理由需使用 MySQL 或 SQLite。
- Rails 8 默认 SQLite 可作为单主机或中小规模部署方案，但不应自动假设其适用于多服务共享系统。
- 原始 SQL 放置在查询对象或模型 scope 之后，每个动态值均需参数化。

## 后台任务与运行时服务

- 新建 Rails 8 应用若吞吐量适中、部署需求简单，使用 **Solid Queue**。
- 若应用需要成熟的可观测性、高吞吐量、已有 Redis 基础设施或 Pro/Enterprise 功能，使用 **Sidekiq**。
- **Solid Cache** 和 **Solid Cable** 在部署模式匹配时使用；涉及跨服务共享行为、高扇出或高级数据结构时使用 Redis。

## 前端

- 服务端渲染的 Rails 应用优先使用 **Hotwire**（Turbo、Stimulus、Importmap、Propshaft）。
- 仅在交互复杂度高、现有产品架构或团队分工需要额外客户端界面时，再引入 React、Vue、Inertia.js 或独立 SPA。
- 视图组件、partial 和展示器仅处理渲染决策；不在模板中执行持久化和授权。

## 身份验证

- 简单会话认证和密码重置使用 Rails 8 身份验证生成器。
- 需要 OAuth、MFA、可确认/可锁定流程、多模型认证或已有大量 Devise 代码时，使用 Devise 或其他成熟的身份验证系统。

## 参考

服务边界和适配器模式参见技能：`backend-patterns`。
