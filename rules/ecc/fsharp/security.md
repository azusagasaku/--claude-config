---
paths:
  - "**/*.fs"
  - "**/*.fsx"
  - "**/*.fsproj"
  - "**/appsettings*.json"
---
# F# 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 F# 特定的安全实践。

## 密钥管理

- 不应在源码中硬编码 API 密钥、令牌或连接字符串
- 使用环境变量、本地开发的 user secrets 以及生产环境的密钥管理器
- 保持 `appsettings.*.json` 中不含真实凭证

```fsharp
// 不推荐
let apiKey = "sk-live-123"

// 推荐
let apiKey =
    configuration["OpenAI:ApiKey"]
    |> Option.ofObj
    |> Option.defaultWith (fun () -> failwith "OpenAI:ApiKey is not configured.")
```

## SQL 注入防护

- 始终使用 ADO.NET、Dapper 或 EF Core 的参数化查询
- 不应将用户输入拼接到 SQL 字符串中
- 使用动态查询组合前先验证排序字段和过滤操作符

```fsharp
let findByCustomer (connection: IDbConnection) customerId =
    task {
        let sql = "SELECT * FROM Orders WHERE CustomerId = @customerId"
        return! connection.QueryAsync<Order>(sql, {| customerId = customerId |})
    }
```

## 输入验证

- 使用类型在应用边界处验证输入
- 使用单例可区分联合表示已验证的值
- 在输入进入领域逻辑前拒绝无效输入

```fsharp
type ValidatedEmail = private ValidatedEmail of string

module ValidatedEmail =
    let create (input: string) =
        if System.Text.RegularExpressions.Regex.IsMatch(input, @"^[^@]+@[^@]+\.[^@]+$") then
            Ok(ValidatedEmail input)
        else
            Error "Invalid email address"

    let value (ValidatedEmail v) = v
```

## 身份验证与授权

- 优先使用框架的认证处理器，而非自行解析令牌
- 在端点或处理器边界处强制执行授权策略
- 不应记录原始令牌、密码或 PII

## 错误处理

- 返回安全的、面向客户端的消息
- 在服务端使用结构化上下文记录详细的异常信息
- 不应在 API 响应中暴露堆栈跟踪、SQL 文本或文件系统路径

## 参考

参见技能：`security-review` 了解更多应用安全审查清单内容。
