---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go 模式

> 本文件对 [common/patterns.md](../common/patterns.md) 进行扩展，补充 Go 常用模式。

## 函数式选项模式

Go 不支持默认参数，通过此模式为构造函数提供可选配置：

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) { s.port = port }
}

func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

## 小接口

接口应在使用方定义，而非在实现方定义。Go 的接口应保持小粒度，通常 1 到 2 个方法为宜。

## 依赖注入

通过构造函数注入依赖：

```go
func NewUserService(repo UserRepository, logger Logger) *UserService {
    return &UserService{repo: repo, logger: logger}
}
```

## 参考

Go 完整模式（并发、错误处理、包组织等）参见 skill: `golang-patterns`。
