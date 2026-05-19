---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
  - "**/appsettings*.json"
---
# C# 安全

> 本文件基于 [common/security.md](../common/security.md) 扩展，补充了 C# 特有内容。

## 密钥管理

- 禁止将 API key、token、连接字符串硬编码在源码中
- 本地开发使用环境变量、user secrets；生产环境使用密钥管理器
- 确保 `appsettings.*.json` 中不含真实凭证

```csharp
// 错误做法
const string ApiKey = "sk-live-123";

// 正确做法
var apiKey = builder.Configuration["OpenAI:ApiKey"]
    ?? throw new InvalidOperationException("OpenAI:ApiKey is not configured.");
```

## SQL 注入防护

- 无论使用 ADO.NET、Dapper 还是 EF Core，一律使用参数化查询
- 禁止将用户输入拼接进 SQL 字符串
- 动态查询组合前须验证排序字段和过滤操作符

```csharp
const string sql = "SELECT * FROM Orders WHERE CustomerId = @customerId";
await connection.QueryAsync<Order>(sql, new { customerId });
```

## 输入验证

- 在应用边界验证 DTO
- 使用 data annotations、FluentValidation 或显式 guard clause
- 业务逻辑执行前拒绝不合法的模型状态

## 认证与授权

- 使用框架内置 auth handler，禁止自行实现 token 解析
- 在端点或 handler 边界强制执行授权策略
- 禁止记录原始 token、密码或 PII

## 错误处理

- 返回给客户端的信息须安全通用
- 服务端记录详细异常，附带结构化上下文
- 禁止在 API 响应中暴露堆栈跟踪、SQL 文本或文件系统路径

## 参考

更广泛的应用安全审查清单见 skill: `security-review`
