---
paths:
  - "**/*.fs"
  - "**/*.fsx"
  - "**/*.fsproj"
---
# F# 测试

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 F# 特定的测试实践。

## 测试框架

- 优先使用 **xUnit** 配合 **FsUnit.xUnit** 实现 F# 友好的断言
- 使用 **Unquote** 进行基于引用的断言，可获得清晰的失败信息
- 使用 **FsCheck.xUnit** 进行基于属性的测试
- 使用 **NSubstitute** 或函数桩进行依赖模拟
- 集成测试需要真实基础设施时使用 **Testcontainers**

## 测试组织

- 在 `tests/` 下镜像 `src/` 的目录结构
- 清晰区分单元测试、集成测试和端到端测试
- 按行为命名测试，而非按实现细节

```fsharp
open Xunit
open Swensen.Unquote

[<Fact>]
let ``PlaceOrder returns success when request is valid`` () =
    let request = { CustomerId = "cust-123"; Items = [ validItem ] }
    let result = OrderService.placeOrder request
    test <@ Result.isOk result @>

[<Fact>]
let ``PlaceOrder returns error when items are empty`` () =
    let request = { CustomerId = "cust-123"; Items = [] }
    let result = OrderService.placeOrder request
    test <@ Result.isError result @>
```

## 使用 FsCheck 进行基于属性的测试

```fsharp
open FsCheck.Xunit

[<Property>]
let ``order total is never negative`` (items: OrderItem list) =
    let total = Order.calculateTotal items
    total >= 0m
```

## ASP.NET Core 集成测试

- 使用 `WebApplicationFactory<TEntryPoint>` 进行 API 集成覆盖
- 通过 HTTP 测试认证、验证和序列化，不应绕过中间件

## 覆盖率

- 目标 80%+ 行覆盖率
- 将覆盖率重点放在领域逻辑、验证、认证和失败路径上
- CI 中执行 `dotnet test`，启用覆盖率收集
