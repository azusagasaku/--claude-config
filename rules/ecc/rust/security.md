---
paths:
  - "**/*.rs"
---
# Rust 安全

> 本文件对 [common/security.md](../common/security.md) 进行扩展，补充 Rust 安全相关内容。

## 密钥管理

- 禁止在源码中硬编码 API 密钥、令牌及凭证
- 通过环境变量获取：`std::env::var("API_KEY")`
- 启动时若缺少必需密钥，应终止进程，不得在缺失配置的状态下运行
- `.env` 文件必须加入 `.gitignore`

```rust
// 不推荐
const API_KEY: &str = "sk-abc123...";

// 推荐 — 使用环境变量，启动时即验证
fn load_api_key() -> anyhow::Result<String> {
    std::env::var("PAYMENT_API_KEY")
        .context("PAYMENT_API_KEY 必须设置")
}
```

## SQL 注入防护

- 始终使用参数化查询 — 禁止通过字符串拼接构造 SQL
- 使用查询构建器或 ORM（sqlx、diesel、sea-orm），通过绑定参数传递值

```rust
// 不推荐 — 格式化字符串拼接 SQL，等同于开放 SQL 注入漏洞
let query = format!("SELECT * FROM users WHERE name = '{name}'");
sqlx::query(&query).fetch_one(&pool).await?;

// 推荐 — 使用 sqlx 的参数化查询
// 占位符语法取决于数据库：Postgres: $1  |  MySQL: ?  |  SQLite: $1
sqlx::query("SELECT * FROM users WHERE name = $1")
    .bind(&name)
    .fetch_one(&pool)
    .await?;
```

## 输入验证

- 所有用户输入在进入系统边界之前均需验证
- 利用类型系统强制执行不变量（参见上述 newtype 模式）
- 解析而不只是验证 — 在边界处将非结构化数据转换为类型化结构体
- 拒绝无效输入时提供明确的错误信息

```rust
// 解析而不只是验证 — 非法状态无法被构造
pub struct Email(String);

impl Email {
    pub fn parse(input: &str) -> Result<Self, ValidationError> {
        let trimmed = input.trim();
        let at_pos = trimmed.find('@')
            .filter(|&p| p > 0 && p < trimmed.len() - 1)
            .ok_or_else(|| ValidationError::InvalidEmail(input.to_string()))?;
        let domain = &trimmed[at_pos + 1..];
        if trimmed.len() > 254 || !domain.contains('.') {
            return Err(ValidationError::InvalidEmail(input.to_string()));
        }
        // 生产环境建议使用经过验证的 email crate（如 `email_address`）
        Ok(Self(trimmed.to_string()))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}
```

## Unsafe 代码

- 尽量减少 `unsafe` 块的使用 — 优先选择安全抽象
- 每个 `unsafe` 块必须附带 `// SAFETY:` 注释，说明其依赖的不变量
- 禁止为了绕过借用检查器而使用 `unsafe`
- 代码审查时重点审计所有 `unsafe` 代码 — 缺少合理说明即为风险信号
- 优先使用围绕 C 库的安全 FFI 封装

```rust
// 推荐 — safety 注释记录了所有必需的不变量
let widget: &Widget = {
    // SAFETY: `ptr` 非空、对齐、指向已初始化的 Widget，
    // 且在其生命周期内不存在可变引用或修改。
    unsafe { &*ptr }
};

// 不推荐 — 没有任何安全说明
unsafe { &*ptr }
```

## 依赖安全

- 执行 `cargo audit` 扫描依赖中的已知 CVE 漏洞
- 执行 `cargo deny check` 检查许可证和公告合规
- 使用 `cargo tree` 审查传递依赖
- 保持依赖更新 — 配置 Dependabot 或 Renovate
- 严格控制依赖数量 — 每新增一个 crate 前应评估其必要性

```bash
# 安全审计
cargo audit

# 拒绝公告、重复版本和受限许可证
cargo deny check

# 检查依赖树
cargo tree
cargo tree -d  # 仅查看重复依赖
```

## 错误消息

- 禁止在 API 响应中暴露内部路径、堆栈追踪或数据库错误
- 服务端记录详细错误日志；客户端仅返回通用消息
- 使用 `tracing` 或 `log` 进行结构化服务端日志

```rust
// 将错误映射到合适的 HTTP 状态码和通用消息
// （示例使用 axum；根据实际框架调整响应类型）
match order_service.find_by_id(id) {
    Ok(order) => Ok((StatusCode::OK, Json(order))),
    Err(ServiceError::NotFound(_)) => {
        tracing::info!(order_id = id, "订单未找到");
        Err((StatusCode::NOT_FOUND, "资源未找到"))
    }
    Err(e) => {
        tracing::error!(order_id = id, error = %e, "意外错误");
        Err((StatusCode::INTERNAL_SERVER_ERROR, "内部服务器错误"))
    }
}
```

## 参考

unsafe 代码指南和所有权模式参见 skill: `rust-patterns`。
通用安全检查清单参见 skill: `security-review`。
