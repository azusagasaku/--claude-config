---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
---
# C# 测试

> 本文件基于 [common/testing.md](../common/testing.md) 扩展，补充了 C# 特有内容。

## 测试框架

- 单元测试和集成测试优先使用 **xUnit**
- 流式断言推荐 **FluentAssertions**
- 依赖 mock 使用 **Moq** 或 **NSubstitute**
- 集成测试需要真实基础设施时使用 **Testcontainers**

## 测试组织

- `tests/` 下镜像 `src/` 的目录结构
- 区分单元测试、集成测试和端到端测试的覆盖范围
- 测试名按行为命名，禁止按实现细节命名

```csharp
public sealed class OrderServiceTests
{
    [Fact]
    public async Task FindByIdAsync_ReturnsOrder_WhenOrderExists()
    {
        // Arrange
        // Act
        // Assert
    }
}
```

## ASP.NET Core 集成测试

- API 集成覆盖使用 `WebApplicationFactory<TEntryPoint>`
- 通过 HTTP 测试认证、验证和序列化，禁止绕过中间件

## 覆盖率

- 目标：80%+ 行覆盖率
- 重点覆盖领域逻辑、验证、认证和失败路径
- CI 中执行 `dotnet test` 并启用覆盖率收集
