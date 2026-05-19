---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go 测试

> 本文件对 [common/testing.md](../common/testing.md) 进行扩展，补充 Go 测试相关内容。

## 框架

使用标准库 `go test` 配合**表驱动测试**。

## 竞态检测

运行测试时添加 `-race` 标志以检测数据竞争：

```bash
go test -race ./...
```

## 覆盖率

```bash
go test -cover ./...
```

## 参考

更多 Go 测试写法及辅助工具参见 skill: `golang-testing`。
