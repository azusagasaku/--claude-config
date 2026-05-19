---
paths:
  - "**/*.kt"
  - "**/*.kts"
---
# Kotlin 安全

> 本文件基于 [common/security.md](../common/security.md) 扩展，补充了 Kotlin 及 Android/KMP 特有内容。

## 密钥管理

- 基本原则：API 密钥、令牌、凭证禁止硬编码在源码中
- 本地开发密钥存放于 `local.properties`（已被 git 忽略）
- 发布版本由 CI 生成密钥，通过 `BuildConfig` 字段注入
- 运行时密钥存储于安全存储：Android 使用 `EncryptedSharedPreferences`，iOS 使用 Keychain

```kotlin
// 禁止
val apiKey = "sk-abc123..."

// 正确做法 — 从 BuildConfig 获取（构建时生成）
val apiKey = BuildConfig.API_KEY

// 正确做法 — 运行时从安全存储获取
val token = secureStorage.get("auth_token")
```

## 网络安全

- 仅使用 HTTPS——配置 `network_security_config.xml` 禁用明文流量
- 敏感端点使用 OkHttp `CertificatePinner` 或 Ktor 对应方案进行证书固定
- 所有 HTTP 客户端必须设置超时——可能默认为无限
- 服务器返回数据使用前须验证和清理

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
```

## 输入验证

- 所有用户输入在发送到 API 前进行验证
- Room/SQLDelight 使用参数化查询——禁止将用户输入拼接进 SQL
- 用户输入的文件路径须清理，防止路径遍历攻击

```kotlin
// 错误做法 — SQL 注入风险
@Query("SELECT * FROM items WHERE name = '$input'")

// 正确做法 — 参数化查询
@Query("SELECT * FROM items WHERE name = :input")
fun findByName(input: String): List<ItemEntity>
```

## 数据保护

- Android 敏感键值数据使用 `EncryptedSharedPreferences`
- 使用 `@Serializable` 时指定显式字段名——禁止泄露内部属性名
- 使用完毕的敏感数据须从内存中清理
- 序列化类添加 `@Keep` 或 ProGuard 规则，防止混淆导致字段丢失

## 身份认证

- 令牌存储于安全存储，禁止使用普通 SharedPreferences
- 实现令牌刷新逻辑，正确处理 401/403
- 登出时清除所有认证状态（令牌、缓存用户数据、cookie）
- 敏感操作使用生物识别认证（`BiometricPrompt`）

## ProGuard / R8

- 所有序列化模型（`@Serializable`、Gson、Moshi）必须添加保留规则
- 基于反射的库（Koin、Retrofit）同样需要保留
- 发布版本须经过充分测试——混淆可能在运行时破坏序列化

## WebView 安全

- 关闭不必要的 JavaScript：`settings.javaScriptEnabled = false`
- WebView 加载 URL 前进行验证
- 禁止在 `@JavascriptInterface` 方法中暴露可访问敏感数据的接口
- 使用 `WebViewClient.shouldOverrideUrlLoading()` 控制导航行为
