---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift 安全

> 本文件基于 [common/security.md](../common/security.md) 扩展，补充了 Swift 特有内容。

## 密钥管理

- 敏感数据（token、密码、密钥）存储于 **Keychain Services**，禁止使用 `UserDefaults`
- 构建时密钥通过环境变量或 `.xcconfig` 文件管理
- 禁止将密钥硬编码在源码中

```swift
let apiKey = ProcessInfo.processInfo.environment["API_KEY"]
guard let apiKey, !apiKey.isEmpty else {
    fatalError("API_KEY not configured")
}
```

## 传输安全

- App Transport Security (ATS) 保持默认开启，禁止关闭
- 关键接口实施证书锁定（certificate pinning）
- 所有服务器证书均须验证

## 输入验证

- 用户输入展示前进行清理，防止注入
- 使用 `URL(string:)` 时进行验证，禁止强制解包
- 来自外部数据源（API、deep link、剪贴板）的数据处理前先验证
