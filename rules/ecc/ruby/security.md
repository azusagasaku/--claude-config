---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
  - "**/Gemfile.lock"
  - "**/config/routes.rb"
  - "**/config/credentials*.yml.enc"
---
# Ruby 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 Ruby 和 Rails 特定的安全实践。

## Rails 默认安全配置

- 涉及状态变更的浏览器请求必须保持 CSRF 防护开启。
- 批量赋值前使用 strong parameters 或类型化边界对象。
- 密钥存储于 Rails credentials、环境变量或密钥管理器。不应提交明文密钥、token、私有凭证或复制的 `.env` 值。

## SQL 与 Active Record

- 优先使用 Active Record 查询 API 和参数化 SQL。
- 不应将请求、cookie、请求头、任务、webhook 中的值直接拼接到 SQL 字符串中。
- 模型回调的职责范围应谨慎控制；与安全相关的副作用必须明确可见并有测试覆盖。

## 身份验证与会话

- 简单会话认证使用 Rails 8 身份验证生成器；需要 OAuth、MFA、可确认、可锁定、多模型认证或已有 Devise 约定时使用 Devise。
- 登录和权限变更后轮换会话。
- 账户恢复流程需有过期时间、一次性令牌、速率限制和审计日志保护。

## 依赖管理

- lockfile 有变动时执行依赖检查：

```bash
bundle exec bundle-audit check --update
bundle exec brakeman --no-progress
```

- 新增 gem 时评估维护者活跃度、原生扩展风险、传递依赖规模，以及是否可用 Rails 核心功能实现相同行为。

## Web 安全

- 模板输出默认转义。将 `html_safe`、`raw` 和自定义清理器视为安全敏感代码。
- 文件上传按内容类型、扩展名、大小和存储目标进行验证。
- 后台任务、webhook、Action Cable 消息和 Turbo Stream 输入均应视为不可信边界。

## 参考

安全审查模式参见技能：`security-review`。
