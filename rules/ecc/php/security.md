---
paths:
  - "**/*.php"
  - "**/composer.lock"
  - "**/composer.json"
---
# PHP 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 PHP 特定的安全实践。

## 输入与输出

- 在框架边界处验证请求输入（`FormRequest`、Symfony Validator 或自定义 DTO 验证均可）。
- 模板输出默认转义；渲染原始 HTML 需有明确的合理理由。
- 不应信任查询参数、cookie、请求头和上传文件元数据，必须先验证再处理。

## 数据库安全

- 所有动态查询均使用预处理语句（`PDO`、Doctrine、Eloquent 查询构建器均可）。
- 不应在控制器/视图中拼接 SQL 字符串，此类做法极易引发注入漏洞。
- ORM 批量赋值应谨慎控制范围，可写字段必须使用白名单。

## 密钥与依赖

- 密钥从环境变量或密钥管理器加载，不应从已提交的配置文件中读取。
- CI 中执行 `composer audit`；添加新包前评估维护者的可靠性。
- 主版本号应有意识地锁定；及时清理过期的包。

## 认证与会话安全

- 使用 `password_hash()` / `password_verify()` 存储密码。
- 认证和权限变更后重新生成会话标识符。
- 涉及状态变更的 Web 请求必须强制执行 CSRF 防护。

## 参考

Laravel 安全参见技能：`laravel-security`。
