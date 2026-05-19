---
paths:
  - "**/*.cs"
  - "**/*.csx"
---
# C# 模式

> 本文件基于 [common/patterns.md](../common/patterns.md) 扩展，补充了 C# 特有内容。

## API 响应模式

```csharp
public sealed record ApiResponse<T>(
    bool Success,
    T? Data = default,
    string? Error = null,
    object? Meta = null);
```

## Repository 模式

```csharp
public interface IRepository<T>
{
    Task<IReadOnlyList<T>> FindAllAsync(CancellationToken cancellationToken);
    Task<T?> FindByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<T> CreateAsync(T entity, CancellationToken cancellationToken);
    Task<T> UpdateAsync(T entity, CancellationToken cancellationToken);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken);
}
```

## Options 模式

配置管理使用强类型 options，禁止在代码库中直接读取裸字符串配置值。

```csharp
public sealed class PaymentsOptions
{
    public const string SectionName = "Payments";
    public required string BaseUrl { get; init; }
    public required string ApiKeySecretName { get; init; }
}
```

## 依赖注入

- 服务边界处依赖接口
- 避免构造函数参数过多——若服务依赖数量异常，应拆分职责
- 明确注册生命周期：无状态/共享服务使用 singleton，请求相关使用 scoped，轻量纯 Worker 使用 transient
