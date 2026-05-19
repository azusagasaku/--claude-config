---
paths:
  - "**/*.kt"
  - "**/*.kts"
---
# Kotlin 模式

> 本文件基于 [common/patterns.md](../common/patterns.md) 扩展，补充了 Kotlin 及 Android/KMP 特有内容。

## 依赖注入

构造函数注入为首选。框架选用 Koin（KMP 场景）或 Hilt（纯 Android 场景）：

```kotlin
// Koin — 声明模块
val dataModule = module {
    single<ItemRepository> { ItemRepositoryImpl(get(), get()) }
    factory { GetItemsUseCase(get()) }
    viewModelOf(::ItemListViewModel)
}

// Hilt — 注解方式
@HiltViewModel
class ItemListViewModel @Inject constructor(
    private val getItems: GetItemsUseCase
) : ViewModel()
```

## ViewModel 模式

单一状态对象、事件接收器、单向数据流：

```kotlin
data class ScreenState(
    val items: List<Item> = emptyList(),
    val isLoading: Boolean = false
)

class ScreenViewModel(private val useCase: GetItemsUseCase) : ViewModel() {
    private val _state = MutableStateFlow(ScreenState())
    val state = _state.asStateFlow()

    fun onEvent(event: ScreenEvent) {
        when (event) {
            is ScreenEvent.Load -> load()
            is ScreenEvent.Delete -> delete(event.id)
        }
    }
}
```

## 仓储模式

- `suspend` 函数返回 `Result<T>` 或自定义错误类型
- 响应式流使用 `Flow`
- 内部协调本地与远程数据源

```kotlin
interface ItemRepository {
    suspend fun getById(id: String): Result<Item>
    suspend fun getAll(): Result<List<Item>>
    fun observeAll(): Flow<List<Item>>
}
```

## UseCase 模式

单一职责，使用 `operator fun invoke` 使调用更自然：

```kotlin
class GetItemUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(id: String): Result<Item> {
        return repository.getById(id)
    }
}

class GetItemsUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(): Result<List<Item>> {
        return repository.getAll()
    }
}
```

## expect/actual（KMP 跨平台）

处理平台差异：

```kotlin
// commonMain
expect fun platformName(): String
expect class SecureStorage {
    fun save(key: String, value: String)
    fun get(key: String): String?
}

// androidMain
actual fun platformName(): String = "Android"
actual class SecureStorage {
    actual fun save(key: String, value: String) { /* EncryptedSharedPreferences */ }
    actual fun get(key: String): String? = null /* ... */
}

// iosMain
actual fun platformName(): String = "iOS"
actual class SecureStorage {
    actual fun save(key: String, value: String) { /* Keychain */ }
    actual fun get(key: String): String? = null /* ... */
}
```

## 协程模式

- ViewModel 中使用 `viewModelScope`，结构化子任务使用 `coroutineScope`
- 冷 Flow 转 StateFlow：`stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), initialValue)`
- 子任务应互不影响的场景使用 `supervisorScope`

## DSL 构建器模式

```kotlin
class HttpClientConfig {
    var baseUrl: String = ""
    var timeout: Long = 30_000
    private val interceptors = mutableListOf<Interceptor>()

    fun interceptor(block: () -> Interceptor) {
        interceptors.add(block())
    }
}

fun httpClient(block: HttpClientConfig.() -> Unit): HttpClient {
    val config = HttpClientConfig().apply(block)
    return HttpClient(config)
}

// 使用示例
val client = httpClient {
    baseUrl = "https://api.example.com"
    timeout = 15_000
    interceptor { AuthInterceptor(tokenProvider) }
}
```

## 参考

协程详细模式见 skill: `kotlin-coroutines-flows`。
模块与分层模式见 skill: `android-clean-architecture`。
