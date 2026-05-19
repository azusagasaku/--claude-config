---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go 安全

> 本文件对 [common/security.md](../common/security.md) 进行扩展，补充 Go 安全相关内容。

## 密钥管理

禁止硬编码密钥，应通过环境变量获取：

```go
apiKey := os.Getenv("OPENAI_API_KEY")
if apiKey == "" {
    log.Fatal("OPENAI_API_KEY 未配置")
}
```

## 安全扫描

- 使用 **gosec** 进行静态安全分析：
  ```bash
  gosec ./...
  ```

## Context 与超时

所有函数应携带 `context.Context`，为请求设置截止时间：

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
```
