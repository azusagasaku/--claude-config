---
paths:
  - "**/*.cs"
  - "**/*.csx"
---
# C# 编码风格

> 本文件基于 [common/coding-style.md](../common/coding-style.md) 扩展，补充了 C# 特有内容。

## 标准

- 遵循当前 .NET 约定，启用可空引用类型
- public 和 internal API 须显式标明访问修饰符
- 一个文件仅包含一个主要类型

## 类型与模型

- 不可变值式模型优先使用 `record` 或 `record struct`
- 具有身份和生命周期的实体使用 `class`
- 服务边界和抽象使用 `interface`
- 应用代码中禁止使用 `dynamic`，使用泛型或显式模型替代

```csharp
public sealed record UserDto(Guid Id, string Email);

public interface IUserRepository
{
    Task<UserDto?> FindByIdAsync(Guid id, CancellationToken cancellationToken);
}
```

## 不可变性

- 共享状态优先使用 `init` setter、构造函数参数和不可变集合
- 产出更新状态时禁止原地修改输入模型

```csharp
public sealed record UserProfile(string Name, string Email);

public static UserProfile Rename(UserProfile profile, string name) =>
    profile with { Name = name };
```

## 异步与错误处理

- 使用 `async`/`await`，禁止阻塞调用（如 `.Result` 或 `.Wait()`）
- public async API 中逐层传递 `CancellationToken`
- 抛出具名异常，日志记录时附带结构化属性

```csharp
public async Task<Order> LoadOrderAsync(
    Guid orderId,
    CancellationToken cancellationToken)
{
    try
    {
        return await repository.FindAsync(orderId, cancellationToken)
            ?? throw new InvalidOperationException($"Order {orderId} was not found.");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to load order {OrderId}", orderId);
        throw;
    }
}
```

## 格式化

- 格式化和分析器修复使用 `dotnet format`
- `using` 指令保持有序，移除未使用的导入
- 表达式体成员仅在保持可读性的前提下使用
