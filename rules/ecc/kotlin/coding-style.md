---
paths:
  - "**/*.kt"
  - "**/*.kts"
---
# Kotlin 编码风格

> 本文件基于 [common/coding-style.md](../common/coding-style.md) 扩展，补充了 Kotlin 特有内容。

## 格式化

- 使用 **ktlint** 或 **Detekt** 管理代码风格，禁止手动调整
- 采用官方 Kotlin 代码风格（`gradle.properties` 中设置 `kotlin.code.style=official`）

## 不可变性

- 优先使用 `val`，仅必要时使用 `var`
- 值类型使用 `data class`；public API 暴露的集合使用不可变类型（`List`、`Map`、`Set`）
- 状态变更采用写时复制：`state.copy(field = newValue)`

## 命名规范

- 函数与属性：`camelCase`
- 类、接口、对象与类型别名：`PascalCase`
- 常量：`SCREAMING_SNAKE_CASE`（`const val` 或 `@JvmStatic`）
- 接口按行为命名，不加 `I` 前缀：使用 `Clickable` 而非 `IClickable`

## 空安全

- 禁止使用 `!!` —— 使用 `?.`、`?:`、`requireNotNull()` 或 `checkNotNull()` 替代
- `?.let {}` 用于有作用域的空安全操作
- 函数可能无结果时直接返回可空类型

```kotlin
// 禁止
val name = user!!.name

// 安全写法
val name = user?.name ?: "Unknown"
val name = requireNotNull(user) { "访问 name 前必须设置 user" }.name
```

## 密封类型

固定状态层级使用 sealed class/interface 建模：

```kotlin
sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String) : UiState<Nothing>
}
```

对密封类型永远使用穷举 `when`，禁止添加 `else` 分支——新增状态时编译器将强制提示遗漏。

## 扩展函数

- 放入以接收者类型命名的文件（`StringExt.kt`、`FlowExt.kt`）
- 控制作用范围——禁止对 `Any` 等过泛类型添加扩展

## 作用域函数

明确各函数用途：
- `let` — 空检查 + 转换：`user?.let { greet(it) }`
- `run` — 以接收者计算：`service.run { fetch(config) }`
- `apply` — 对象配置：`builder.apply { timeout = 30 }`
- `also` — 副作用：`result.also { log(it) }`
- 嵌套最多 2 层，超出则重构

## 错误处理

- 使用 `Result<T>` 或自定义密封类型
- `runCatching {}` 包装可能抛异常的代码
- `CancellationException` 必须重新抛出，禁止吞掉
- 禁止以 `try-catch` 替代控制流

```kotlin
// 错误做法 — 用异常做控制流
val user = try { repository.getUser(id) } catch (e: NotFoundException) { null }

// 正确做法 — 返回可空类型
val user: User? = repository.findUser(id)
```
