---
paths:
  - "**/*.fs"
  - "**/*.fsx"
---
# F# 模式

> 本文件扩展了 [common/patterns.md](../common/patterns.md)，补充 F# 特定的设计模式。

## Result 类型处理错误

使用 `Result<'T, 'TError>` 配合铁道导向编程，对预期失败不抛出异常。

```fsharp
type OrderError =
    | InvalidCustomer of string
    | EmptyItems
    | ItemOutOfStock of sku: string

let validateOrder (request: CreateOrderRequest) : Result<ValidatedOrder, OrderError> =
    if String.IsNullOrWhiteSpace request.CustomerId then
        Error(InvalidCustomer "CustomerId is required")
    elif request.Items |> List.isEmpty then
        Error EmptyItems
    else
        Ok { CustomerId = request.CustomerId; Items = request.Items }
```

## Option 处理缺失值

优先使用 `Option<'T>` 而非 null。使用 `Option.map`、`Option.bind` 和 `Option.defaultValue` 进行转换。

```fsharp
let findUser (id: Guid) : User option =
    users |> Map.tryFind id

let getUserEmail userId =
    findUser userId
    |> Option.map (fun u -> u.Email)
    |> Option.defaultValue "unknown@example.com"
```

## 可区分联合用于领域建模

显式建模业务状态。编译器强制执行穷尽性处理。

```fsharp
type PaymentState =
    | AwaitingPayment of amount: decimal
    | Paid of paidAt: DateTimeOffset * transactionId: string
    | Refunded of refundedAt: DateTimeOffset * reason: string
    | Failed of error: string

let describePayment = function
    | AwaitingPayment amount -> $"Awaiting payment of {amount:C}"
    | Paid (at, txn) -> $"Paid at {at} (txn: {txn})"
    | Refunded (at, reason) -> $"Refunded at {at}: {reason}"
    | Failed error -> $"Payment failed: {error}"
```

## 计算表达式

使用计算表达式简化可能失败的顺序操作。

```fsharp
let placeOrder request =
    result {
        let! validated = validateOrder request
        let! inventory = checkInventory validated.Items
        let! order = createOrder validated inventory
        return order
    }
```

## 模块组织

- 将相关函数按模块分组，而非按类
- 使用 `[<RequireQualifiedAccess>]` 防止名称冲突
- 保持模块短小，专注单一职责

```fsharp
[<RequireQualifiedAccess>]
module Order =
    let create customerId items = { Id = Guid.NewGuid(); CustomerId = customerId; Items = items; Status = Pending }
    let confirm order = { order with Status = Confirmed(DateTimeOffset.UtcNow) }
    let cancel reason order = { order with Status = Cancelled reason }
```

## 依赖注入

- 将依赖定义为函数参数或函数记录
- 谨慎使用接口，主要在与 .NET 库的边界处使用
- 优先使用部分应用将依赖注入处理流水线

```fsharp
type OrderDeps =
    { FindOrder: Guid -> Task<Order option>
      SaveOrder: Order -> Task<unit>
      SendNotification: Order -> Task<unit> }

let processOrder (deps: OrderDeps) orderId =
    task {
        match! deps.FindOrder orderId with
        | None -> return Error "Order not found"
        | Some order ->
            let confirmed = Order.confirm order
            do! deps.SaveOrder confirmed
            do! deps.SendNotification confirmed
            return Ok confirmed
    }
```
