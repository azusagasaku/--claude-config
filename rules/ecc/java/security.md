---
paths:
  - "**/*.java"
---
# Java 安全

> 本文件基于 [common/security.md](../common/security.md) 扩展，补充了 Java 特有内容。

## 密钥管理

- 基本原则：API 密钥、令牌和凭证禁止硬编码在源码中
- 使用环境变量：`System.getenv("API_KEY")`
- 生产环境密钥使用专用密钥管理器（Vault、AWS Secrets Manager 等）
- 包含密钥的本地配置文件必须加入 `.gitignore`

```java
// 禁止这样做
private static final String API_KEY = "sk-abc123...";

// 正确做法 — 从环境变量获取
String apiKey = System.getenv("PAYMENT_API_KEY");
Objects.requireNonNull(apiKey, "PAYMENT_API_KEY 必须设置");
```

## SQL 注入防护

- 始终使用参数化查询，禁止将用户输入直接拼接进 SQL 字符串
- 使用 `PreparedStatement` 或框架提供的参数化查询 API
- 所有传入原生查询的输入必须验证与清理

```java
// 错误做法 — 字符串拼接导致 SQL 注入风险
Statement stmt = conn.createStatement();
String sql = "SELECT * FROM orders WHERE name = '" + name + "'";
stmt.executeQuery(sql);

// 正确做法 — PreparedStatement 参数化
PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders WHERE name = ?");
ps.setString(1, name);

// 正确做法 — JDBC template
jdbcTemplate.query("SELECT * FROM orders WHERE name = ?", mapper, name);
```

## 输入验证

- 所有用户输入在进入系统前必须验证
- DTO 上使用 Bean Validation（`@NotNull`、`@NotBlank`、`@Size`）
- 文件路径和用户提供的字符串须在使用前清理
- 验证失败时返回清晰的错误提示

```java
// 手动验证
public Order createOrder(String customerName, BigDecimal amount) {
    if (customerName == null || customerName.isBlank()) {
        throw new IllegalArgumentException("客户名称是必填的");
    }
    if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
        throw new IllegalArgumentException("金额必须为正数");
    }
    return new Order(customerName, amount);
}
```

## 认证与授权

- 禁止自行实现认证加密逻辑——使用经过验证的成熟库
- 密码存储使用 bcrypt 或 Argon2，禁止使用 MD5/SHA1
- 在每个服务边界强制执行授权检查
- 日志中排除敏感数据——密码、令牌、PII 信息不得出现在日志中

## 依赖安全

- 定期执行 `mvn dependency:tree` 或 `./gradlew dependencies` 检查传递依赖
- 使用 OWASP Dependency-Check 或 Snyk 扫描已知漏洞
- 保持依赖更新——配置 Dependabot 或 Renovate 自动化管理

## 错误消息

- 禁止在 API 响应中暴露堆栈追踪、内部路径或 SQL 错误信息
- 在处理器层将异常映射为安全的通用客户端消息
- 服务端记录详细日志用于排查，返回给客户端的信息应通用化

```java
// 记录详细日志，返回通用消息
try {
    return orderService.findById(id);
} catch (OrderNotFoundException ex) {
    log.warn("订单未找到: id={}", id);
    return ApiResponse.error("资源未找到");  // 通用消息，不暴露内部信息
} catch (Exception ex) {
    log.error("处理订单异常 id={}", id, ex);
    return ApiResponse.error("内部服务器错误");  // 禁止暴露 ex.getMessage()
}
```

## 参考

Spring Security 认证与授权模式见 skill: `springboot-security`。
Quarkus 安全（JWT/OIDC、RBAC 和 CDI）见 skill: `quarkus-security`。
通用安全检查清单见 skill: `security-review`。
