---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift 编码风格

> 本文件基于 [common/coding-style.md](../common/coding-style.md) 扩展，补充了 Swift 特有内容。

## 格式化

- 格式化和风格检查使用 **SwiftFormat** + **SwiftLint**
- Xcode 16+ 内置 `swift-format` 也可使用

## 不可变性

- 优先使用 `let`，仅编译器报错时改为 `var`
- 默认使用 `struct`（值类型），仅在需要引用语义时使用 `class`

## 命名

遵循 [Apple API 设计指南](https://www.swift.org/documentation/api-design-guidelines/)：

- 调用点语义清晰——移除冗余词汇
- 方法名和属性名描述行为，而非类型
- 常量使用 `static let`，禁止全局常量

## 错误处理

Swift 6+ 提供类型化 throw 与模式匹配：

```swift
func load(id: String) throws(LoadError) -> Item {
    guard let data = try? read(from: path) else {
        throw .fileNotFound(id)
    }
    return try decode(data)
}
```

## 并发

开启 Swift 6 严格并发检查。优先使用：

- `Sendable` 值类型用于跨隔离域数据传递
- Actor 管理共享可变状态
- 结构化并发（`async let`、`TaskGroup`），禁止直接使用非结构化 `Task {}`
