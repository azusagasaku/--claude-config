---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go 编码风格

> 本文件对 [common/coding-style.md](../common/coding-style.md) 进行扩展，补充 Go 语言相关内容。

## 格式化

- **gofmt** 和 **goimports** 为必需工具 — Go 社区对格式化有统一标准。

## 设计原则

- 优先接受接口，返回结构体
- 接口应保持小粒度，通常 1 到 3 个方法即可

## 错误处理

错误返回时应包装上下文信息，避免仅返回原始 err：

```go
if err != nil {
    return fmt.Errorf("创建用户失败: %w", err)
}
```

## 参考

更多 Go 惯用法和模式参见 skill: `golang-patterns`。
