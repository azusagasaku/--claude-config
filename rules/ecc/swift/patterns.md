---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift 模式

> 本文件基于 [common/patterns.md](../common/patterns.md) 扩展，补充了 Swift 特有内容。

## 面向协议设计

定义小巧、职责单一的协议。通过协议扩展提供共享默认实现：

```swift
protocol Repository: Sendable {
    associatedtype Item: Identifiable & Sendable
    func find(by id: Item.ID) async throws -> Item?
    func save(_ item: Item) async throws
}
```

## 值类型

- 数据传输对象和模型使用 struct
- 使用带关联值的 enum 建模不同状态：

```swift
enum LoadState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}
```

## Actor 模式

使用 actor 管理共享可变状态，替代手动锁或 dispatch queue：

```swift
actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: Value] = [:]

    func get(_ key: Key) -> Value? { storage[key] }
    func set(_ key: Key, value: Value) { storage[key] = value }
}
```

## 依赖注入

使用带默认参数的协议注入——生产代码使用默认实现，测试中替换为 mock：

```swift
struct UserService {
    private let repository: any UserRepository

    init(repository: any UserRepository = DefaultUserRepository()) {
        self.repository = repository
    }
}
```

## 参考

- 基于 Actor 的持久化模式见 skill: `swift-actor-persistence`
- 基于协议的依赖注入与测试见 skill: `swift-protocol-di-testing`
