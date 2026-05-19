---
paths:
  - "**/*.java"
---
# Java 编码风格

> 本文件基于 [common/coding-style.md](../common/coding-style.md) 扩展，补充了 Java 特有内容。

## 格式化

- 使用 **google-java-format** 或 **Checkstyle**（Google 风格或 Sun 风格）进行自动格式化，禁止手动调整
- 每个文件仅包含一个 public 顶层类型
- 缩进保持一致：2 格或 4 格空格均可，遵循项目现有风格
- 成员排序：常量 -> 字段 -> 构造函数 -> public 方法 -> protected 方法 -> private 方法

## 不可变性

- 值类型优先使用 `record`（Java 16+）
- 字段默认声明为 `final`，仅必要时移除
- 从 public API 返回集合时执行防御性拷贝：`List.copyOf()`、`Map.copyOf()`、`Set.copyOf()`
- 写时复制：返回新实例，禁止原地修改

```java
// 不可变值类型 — record
public record OrderSummary(Long id, String customerName, BigDecimal total) {}

// final 字段，无 setter
public class Order {
    private final Long id;
    private final List<LineItem> items;

    public List<LineItem> getItems() {
        return List.copyOf(items);
    }
}
```

## 命名规范

- 类、接口、record、枚举使用 `PascalCase`
- 方法、字段、参数、局部变量使用 `camelCase`
- `static final` 常量使用 `SCREAMING_SNAKE_CASE`
- 包名全部小写，按反向域名组织（`com.example.app.service`）

## 现代 Java 特性

优先采用以下特性以提升代码清晰度：
- **Records** — DTO 和值类型首选（Java 16+）
- **Sealed classes** — 已知固定层级时封闭类型（Java 17+）
- **模式匹配 instanceof** — 避免显式强制转换（Java 16+）
- **文本块** — 多行字符串如 SQL、JSON 模板（Java 15+）
- **Switch 表达式** — 箭头语法（Java 14+）
- **模式匹配 switch** — 对 sealed 类型穷举处理（Java 21+）

```java
// 模式匹配 instanceof
if (shape instanceof Circle c) {
    return Math.PI * c.radius() * c.radius();
}

// Sealed 类型层级
public sealed interface PaymentMethod permits CreditCard, BankTransfer, Wallet {}

// Switch 表达式
String label = switch (status) {
    case ACTIVE -> "Active";
    case SUSPENDED -> "Suspended";
    case CLOSED -> "Closed";
};
```

## Optional 使用规范

- 可能无结果的查询方法返回 `Optional<T>`
- 使用 `map()`、`flatMap()`、`orElseThrow()` 链式处理 —— 禁止在未检查 `isPresent()` 的情况下直接调用 `get()`
- `Optional` 不作为字段类型或方法参数使用

```java
// 正确用法
return repository.findById(id)
    .map(ResponseDto::from)
    .orElseThrow(() -> new OrderNotFoundException(id));

// 错误用法 — Optional 作为参数
public void process(Optional<String> name) {}
```

## 错误处理

- 业务领域错误使用非受检异常
- 继承 `RuntimeException` 创建自定义领域异常
- 仅在顶层兜底处理器中使用 `catch (Exception e)`，禁止在业务逻辑中滥用
- 异常消息中携带关键上下文信息

```java
public class OrderNotFoundException extends RuntimeException {
    public OrderNotFoundException(Long id) {
        super("订单未找到: id=" + id);
    }
}
```

## Streams

- 适合数据转换场景，但流水线操作控制在 3-4 步以内
- 可读性允许时优先使用方法引用：`.map(Order::getTotal)`
- Stream 操作中禁止产生副作用
- 逻辑复杂时使用普通循环替代长链式 Stream 调用

## 参考

完整的编码标准见 skill: `java-coding-standards`。
JPA/Hibernate 实体设计模式见 skill: `jpa-patterns`。
