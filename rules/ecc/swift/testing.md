---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift 测试

> 本文件基于 [common/testing.md](../common/testing.md) 扩展，补充了 Swift 特有内容。

## 测试框架

新测试使用 **Swift Testing**（`import Testing`），通过 `@Test` 和 `#expect` 编写：

```swift
@Test("User creation validates email")
func userCreationValidatesEmail() throws {
    #expect(throws: ValidationError.invalidEmail) {
        try User(email: "not-an-email")
    }
}
```

## 测试隔离

每个测试获取全新实例——在 `init` 中初始化，在 `deinit` 中清理。测试之间禁止共享可变状态。

## 参数化测试

```swift
@Test("Validates formats", arguments: ["json", "xml", "csv"])
func validatesFormat(format: String) throws {
    let parser = try Parser(format: format)
    #expect(parser.isValid)
}
```

## 覆盖率

```bash
swift test --enable-code-coverage
```

## 参考

基于协议的依赖注入与 Swift Testing mock 模式见 skill: `swift-protocol-di-testing`
