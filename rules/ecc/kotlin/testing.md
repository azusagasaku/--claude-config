---
paths:
  - "**/*.kt"
  - "**/*.kts"
---
# Kotlin 测试

> 本文件基于 [common/testing.md](../common/testing.md) 扩展，补充了 Kotlin 及 Android/KMP 特有内容。

## 测试框架

- **kotlin.test** — KMP 多平台测试（`@Test`、`assertEquals`、`assertTrue`）
- **JUnit 4/5** — Android 专用测试
- **Turbine** — Flow 和 StateFlow 测试
- **kotlinx-coroutines-test** — 协程测试（`runTest`、`TestDispatcher`）

## 使用 Turbine 测试 ViewModel

```kotlin
@Test
fun `loading state emitted then data`() = runTest {
    val repo = FakeItemRepository()
    repo.addItem(testItem)
    val viewModel = ItemListViewModel(GetItemsUseCase(repo))

    viewModel.state.test {
        assertEquals(ItemListState(), awaitItem())     // 初始状态
        viewModel.onEvent(ItemListEvent.Load)
        assertTrue(awaitItem().isLoading)               // 加载中
        assertEquals(listOf(testItem), awaitItem().items) // 已加载
    }
}
```

## 优先编写 Fake，减少 Mock

手写 Fake 优于 mock 框架——Fake 易于理解和维护：

```kotlin
class FakeItemRepository : ItemRepository {
    private val items = mutableListOf<Item>()
    var fetchError: Throwable? = null

    override suspend fun getAll(): Result<List<Item>> {
        fetchError?.let { return Result.failure(it) }
        return Result.success(items.toList())
    }

    override fun observeAll(): Flow<List<Item>> = flowOf(items.toList())

    fun addItem(item: Item) { items.add(item) }
}
```

## 协程测试

```kotlin
@Test
fun `parallel operations complete`() = runTest {
    val repo = FakeRepository()
    val result = loadDashboard(repo)
    advanceUntilIdle()
    assertNotNull(result.items)
    assertNotNull(result.stats)
}
```

使用 `runTest` 即可——自动推进虚拟时间并提供 `TestScope`。

## Ktor MockEngine

```kotlin
val mockEngine = MockEngine { request ->
    when (request.url.encodedPath) {
        "/api/items" -> respond(
            content = Json.encodeToString(testItems),
            headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString())
        )
        else -> respondError(HttpStatusCode.NotFound)
    }
}

val client = HttpClient(mockEngine) {
    install(ContentNegotiation) { json() }
}
```

## Room / SQLDelight 测试

- Room：使用 `Room.inMemoryDatabaseBuilder()` 创建内存数据库
- SQLDelight：JVM 测试使用 `JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)`

```kotlin
@Test
fun `insert and query items`() = runTest {
    val driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
    Database.Schema.create(driver)
    val db = Database(driver)

    db.itemQueries.insert("1", "Sample Item", "description")
    val items = db.itemQueries.getAll().executeAsList()
    assertEquals(1, items.size)
}
```

## 测试命名

使用反引号包裹描述性名称：

```kotlin
@Test
fun `search with empty query returns all items`() = runTest { }

@Test
fun `delete item emits updated list without deleted item`() = runTest { }
```

## 测试目录组织

```
src/
├── commonTest/kotlin/     # 共享测试（ViewModel、UseCase、Repository）
├── androidUnitTest/kotlin/ # Android 单元测试（JUnit）
├── androidInstrumentedTest/kotlin/  # 插桩测试（Room、UI）
└── iosTest/kotlin/        # iOS 专用测试
```

最低标准：每个功能的 ViewModel + UseCase 测试必须覆盖。
