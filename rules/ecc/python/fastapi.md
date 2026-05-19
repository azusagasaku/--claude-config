---
paths:
  - "**/app/**/*.py"
  - "**/fastapi/**/*.py"
  - "**/*_api.py"
---
# FastAPI 规则

在通用 Python 规则的基础上，FastAPI 项目还应遵循以下补充规则。

## 项目结构

- 应用构建逻辑统一封装于 `create_app()` 中。
- 路由处理函数应保持轻量，将持久化和业务逻辑抽取到 service 或 CRUD 辅助模块。
- 请求 schema、更新 schema、响应 schema 应分别定义，避免混用。
- 数据库会话和认证逻辑通过依赖项（dependencies）注入。

## 异步

- I/O 操作的端点使用 `async def`。
- 异步端点内应使用异步数据库客户端和 HTTP 客户端，避免混用同步库。
- 禁止在异步路由中调用 `requests`、同步 SQLAlchemy 会话，或执行阻塞式文件/网络操作。

## 依赖注入

```python
@router.get("/users/{user_id}")
async def get_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ...
```

不应在路由处理函数内自行创建 `SessionLocal()` 或长生命周期客户端，交由 FastAPI 依赖系统统一管理。

## Schema 设计

- 响应模型中禁止暴露密码、密码哈希、access token、refresh token 及内部认证状态。
- 返回应用数据的端点应使用 `response_model`。
- 优先使用 Pydantic 字段约束进行校验，避免手写校验逻辑。

## 安全性

- CORS origins 应作为运行环境相关的配置项，禁止硬编码。
- 禁止同时使用通配符 origin 和带凭证的 CORS。
- JWT 的过期时间、签发者（issuer）、受众（audience）、算法均需校验。
- 认证端点及高频写操作端点应添加速率限制。
- 日志中需对凭证、cookie、authorization 头、token 等敏感信息进行脱敏。

## 测试

- 仅覆写 `Depends` 中实际使用的依赖项，不应覆写无关依赖。
- 测试完成后须清理 `app.dependency_overrides`。
- 异步应用优先使用异步测试客户端。

更多信息参见 skill：`fastapi-patterns`。
