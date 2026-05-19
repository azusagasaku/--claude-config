---
paths:
  - "**/*.java"
---
# Java 模式

> 本文件基于 [common/patterns.md](../common/patterns.md) 扩展，补充了 Java 特有内容。

## 仓储模式

将数据访问封装在接口之后，业务层不感知底层存储实现：

```java
public interface OrderRepository {
    Optional<Order> findById(Long id);
    List<Order> findAll();
    Order save(Order order);
    void deleteById(Long id);
}
```

具体实现可任意替换（JPA、JDBC、内存实现等）。

## 服务层

业务逻辑集中于 Service 类，Controller 和 Repository 保持轻量：

```java
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentGateway paymentGateway;

    public OrderService(OrderRepository orderRepository, PaymentGateway paymentGateway) {
        this.orderRepository = orderRepository;
        this.paymentGateway = paymentGateway;
    }

    public OrderSummary placeOrder(CreateOrderRequest request) {
        var order = Order.from(request);
        paymentGateway.charge(order.total());
        var saved = orderRepository.save(order);
        return OrderSummary.from(saved);
    }
}
```

## 构造函数注入

始终使用构造函数注入，禁止字段注入——字段注入无法脱离框架测试：

```java
// 正确 — 构造函数注入（可测试、不可变）
public class NotificationService {
    private final EmailSender emailSender;

    public NotificationService(EmailSender emailSender) {
        this.emailSender = emailSender;
    }
}

// 错误 — 字段注入（依赖反射，测试困难）
public class NotificationService {
    @Inject // 或 @Autowired
    private EmailSender emailSender;
}
```

## DTO 映射

DTO 使用 record 定义，映射逻辑置于 Service/Controller 层：

```java
public record OrderResponse(Long id, String customer, BigDecimal total) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(order.getId(), order.getCustomerName(), order.getTotal());
    }
}
```

## 构建器模式

适用于构造参数较多的对象：

```java
public class SearchCriteria {
    private final String query;
    private final int page;
    private final int size;
    private final String sortBy;

    private SearchCriteria(Builder builder) {
        this.query = builder.query;
        this.page = builder.page;
        this.size = builder.size;
        this.sortBy = builder.sortBy;
    }

    public static class Builder {
        private String query = "";
        private int page = 0;
        private int size = 20;
        private String sortBy = "id";

        public Builder query(String query) { this.query = query; return this; }
        public Builder page(int page) { this.page = page; return this; }
        public Builder size(int size) { this.size = size; return this; }
        public Builder sortBy(String sortBy) { this.sortBy = sortBy; return this; }
        public SearchCriteria build() { return new SearchCriteria(this); }
    }
}
```

## 密封类型领域建模

```java
public sealed interface PaymentResult permits PaymentSuccess, PaymentFailure {
    record PaymentSuccess(String transactionId, BigDecimal amount) implements PaymentResult {}
    record PaymentFailure(String errorCode, String message) implements PaymentResult {}
}

// 穷举处理（Java 21+）
String message = switch (result) {
    case PaymentSuccess s -> "已支付: " + s.transactionId();
    case PaymentFailure f -> "失败: " + f.errorCode();
};
```

## API 响应信封

统一 API 返回格式：

```java
public record ApiResponse<T>(boolean success, T data, String error) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null);
    }
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, null, message);
    }
}
```

## 参考

Spring Boot 架构模式见 skill: `springboot-patterns`。
Quarkus 架构模式（REST、Panache 和消息）见 skill: `quarkus-patterns`。
实体设计与查询优化见 skill: `jpa-patterns`。
