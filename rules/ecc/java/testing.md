---
paths:
  - "**/*.java"
---
# Java 测试

> 本文件基于 [common/testing.md](../common/testing.md) 扩展，补充了 Java 特有内容。

## 测试框架

- **JUnit 5**（`@Test`、`@ParameterizedTest`、`@Nested`、`@DisplayName`）
- **AssertJ** — 流式断言，写法简洁：`assertThat(result).isEqualTo(expected)`
- **Mockito** — 依赖模拟
- **Testcontainers** — 集成测试中需要真实数据库或外部服务时使用

## 测试目录结构

```
src/test/java/com/example/app/
  service/           # 服务层单元测试
  controller/        # Web 层 / API 测试
  repository/        # 数据访问测试
  integration/       # 跨层集成测试
```

在 `src/test/java` 下镜像 `src/main/java` 的包结构。

## 单元测试示例

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    private OrderService orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderService(orderRepository);
    }

    @Test
    @DisplayName("findById 当订单存在时返回订单")
    void findById_existingOrder_returnsOrder() {
        var order = new Order(1L, "Alice", BigDecimal.TEN);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));

        var result = orderService.findById(1L);

        assertThat(result.customerName()).isEqualTo("Alice");
        verify(orderRepository).findById(1L);
    }

    @Test
    @DisplayName("findById 当订单不存在时抛异常")
    void findById_missingOrder_throws() {
        when(orderRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> orderService.findById(99L))
            .isInstanceOf(OrderNotFoundException.class)
            .hasMessageContaining("99");
    }
}
```

## 参数化测试

单个测试覆盖多组数据，避免重复代码：

```java
@ParameterizedTest
@CsvSource({
    "100.00, 10, 90.00",
    "50.00, 0, 50.00",
    "200.00, 25, 150.00"
})
@DisplayName("折扣计算正确")
void applyDiscount(BigDecimal price, int pct, BigDecimal expected) {
    assertThat(PricingUtils.discount(price, pct)).isEqualByComparingTo(expected);
}
```

## 集成测试

使用 Testcontainers 连接真实数据库：

```java
@Testcontainers
class OrderRepositoryIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    private OrderRepository repository;

    @BeforeEach
    void setUp() {
        var dataSource = new PGSimpleDataSource();
        dataSource.setUrl(postgres.getJdbcUrl());
        dataSource.setUser(postgres.getUsername());
        dataSource.setPassword(postgres.getPassword());
        repository = new JdbcOrderRepository(dataSource);
    }

    @Test
    void save_and_findById() {
        var saved = repository.save(new Order(null, "Bob", BigDecimal.ONE));
        var found = repository.findById(saved.getId());
        assertThat(found).isPresent();
    }
}
```

Spring Boot 集成测试见 skill: `springboot-tdd`。
Quarkus 集成测试见 skill: `quarkus-tdd`。

## 测试命名

名称应当明确表达被测行为，配合 `@DisplayName` 使用：
- 方法名格式：`methodName_scenario_expectedBehavior()`
- `@DisplayName` 以自然语言描述测试意图

## 覆盖率

- 目标：80% 以上行覆盖
- 使用 JaCoCo 生成覆盖率报告
- 重点覆盖 Service 和领域逻辑，简单 getter 和配置类无需测试

## 参考

Spring Boot TDD 模式（MockMvc 和 Testcontainers）见 skill: `springboot-tdd`。
Quarkus TDD 模式（REST Assured 和 Dev Services）见 skill: `quarkus-tdd`。
测试编写规范见 skill: `java-coding-standards`。
