---
paths:
  - "**/*.fs"
  - "**/*.fsx"
---
# F# 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 F# 特定的编码约定。

## 标准

- 遵循标准的 F# 约定，利用类型系统保证正确性
- 默认优先使用不可变性；仅在具有充分性能理由时才使用 `mutable`
- 模块保持聚焦和内聚

## 类型与模型

- 优先使用可区分联合（discriminated union）进行领域建模，而非类继承体系
- 使用记录（record）表示具有命名字段的数据
- 使用单例可区分联合为基本类型创建类型安全的包装器
- 除非需要互操作或可变状态，否则不应使用类

```fsharp
type EmailAddress = EmailAddress of string

type OrderStatus =
    | Pending
    | Confirmed of confirmedAt: DateTimeOffset
    | Shipped of trackingNumber: string
    | Cancelled of reason: string

type Order =
    { Id: Guid
      CustomerId: string
      Status: OrderStatus
      Items: OrderItem list }
```

## 不可变性

- 记录默认不可变；使用 `with` 表达式进行更新
- 优先使用 `list`、`map`、`set` 而非可变集合
- 领域逻辑中不应使用 `ref` 单元和可变字段

```fsharp
let rename (profile: UserProfile) newName =
    { profile with Name = newName }
```

## 函数风格

- 优先使用小而可组合的函数，而非大型方法
- 使用管道运算符 `|>` 构建可读的数据处理流水线
- 优先使用模式匹配，而非 if/else 链
- 使用 `Option` 替代 null；可能失败的操作使用 `Result`

```fsharp
let processOrder order =
    order
    |> validateItems
    |> Result.bind calculateTotal
    |> Result.map applyDiscount
    |> Result.mapError OrderError
```

## 异步与错误处理

- 使用 `task { }` 与 .NET 异步 API 进行互操作
- 使用 `async { }` 实现 F# 原生异步工作流
- 通过公共异步 API 传播 `CancellationToken`
- 对预期内可能发生的失败，优先使用 `Result` 和铁道导向编程，而非抛出异常

```fsharp
let loadOrderAsync (orderId: Guid) (ct: CancellationToken) =
    task {
        let! order = repository.FindAsync(orderId, ct)
        return
            order
            |> Option.defaultWith (fun () ->
                failwith $"Order {orderId} was not found.")
    }
```

## 格式化

- 使用 `fantomas` 自动格式化
- 优先使用有意义的空白；避免不必要的括号
- 移除未使用的 `open` 声明

### Open 声明顺序

将 `open` 语句分为四组，组间空一行，每组内部按字母序排列：

1. `System.*`
2. `Microsoft.*`
3. 第三方命名空间
4. 自有/项目命名空间

```fsharp
open System
open System.Collections.Generic
open System.Threading.Tasks

open Microsoft.AspNetCore.Http
open Microsoft.Extensions.Logging

open FsCheck.Xunit
open Swensen.Unquote

open MyApp.Domain
open MyApp.Infrastructure
```
