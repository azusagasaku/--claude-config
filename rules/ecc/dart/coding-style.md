---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/analysis_options.yaml"
---
# Dart/Flutter 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 Dart 和 Flutter 特定的编码约定。

## 格式化

- 所有 `.dart` 文件使用 **dart format** —— 在 CI 中强制执行 (`dart format --set-exit-if-changed .`)
- 行长度：80 字符（dart format 默认）
- 多行参数/参数列表末尾添加尾随逗号，可改善差异对比和格式化结果

## 不可变性

- 局部变量优先使用 `final`，编译时常量使用 `const`
- 所有字段均为 `final` 时使用 `const` 构造函数
- 从公共 API 返回不可修改的集合（`List.unmodifiable`、`Map.unmodifiable`）
- 在不可变状态类中使用 `copyWith()` 进行状态变更

```dart
// 不推荐
var count = 0;
List<String> items = ['a', 'b'];

// 推荐
final count = 0;
const items = ['a', 'b'];
```

## 命名

遵循 Dart 命名约定：
- 变量、参数和命名构造函数使用 `camelCase`
- 类、枚举、typedef 和扩展使用 `PascalCase`
- 文件名和库名使用 `snake_case`
- 顶层 `const` 声明的常量使用 `SCREAMING_SNAKE_CASE`
- 私有成员添加前缀 `_`
- 扩展名应描述其扩展的类型：使用 `StringExtensions`，而非 `MyHelpers`

## 空安全

- 不应使用 `!`（感叹号操作符）—— 优先使用 `?.`、`??`、`if (x != null)` 或 Dart 3 模式匹配；仅在 null 值属于编程错误且崩溃为正确行为时使用 `!`
- 不应使用 `late`，除非能确保首次使用前必定初始化（优先考虑可 null 或构造函数初始化）
- 构造函数中必需的参数使用 `required`

```dart
// 不推荐 —— user 为 null 时发生运行时崩溃
final name = user!.name;

// 推荐 —— 空安全操作符
final name = user?.name ?? 'Unknown';

// 推荐 —— Dart 3 模式匹配（穷举，编译器检查）
final name = switch (user) {
  User(:final name) => name,
  null => 'Unknown',
};

// 推荐 —— null 守卫提前返回
String getUserName(User? user) {
  if (user == null) return 'Unknown';
  return user.name; // 守卫后被提升为非 null
}
```

## 密封类型与模式匹配（Dart 3+）

使用密封类建模封闭的状态层次结构：

```dart
sealed class AsyncState<T> {
  const AsyncState();
}

final class Loading<T> extends AsyncState<T> {
  const Loading();
}

final class Success<T> extends AsyncState<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends AsyncState<T> {
  const Failure(this.error);
  final Object error;
}
```

密封类型必须始终使用穷举 `switch` —— 不应使用 default/通配符：

```dart
// 不推荐
if (state is Loading) { ... }

// 推荐
return switch (state) {
  Loading() => const CircularProgressIndicator(),
  Success(:final data) => DataWidget(data),
  Failure(:final error) => ErrorWidget(error.toString()),
};
```

## 错误处理

- 在 `on` 子句中指定异常类型 —— 不应使用裸 `catch (e)`
- 不应捕获 `Error` 子类型 —— 它们表示编程错误
- 可恢复的错误使用 `Result` 风格类型或密封类
- 不应使用异常进行流程控制

```dart
// 不推荐
try {
  await fetchUser();
} catch (e) {
  log(e.toString());
}

// 推荐
try {
  await fetchUser();
} on NetworkException catch (e) {
  log('Network error: ${e.message}');
} on NotFoundException {
  handleNotFound();
}
```

## 异步 / Futures

- 始终 `await` Futures，或显式调用 `unawaited()` 表明有意"发射后不管"
- 如果函数从不 `await` 任何内容，不应标记为 `async`
- 并发操作使用 `Future.wait` / `Future.any`
- 在任何 `await` 之后使用 `BuildContext` 前，先检查 `context.mounted`（Flutter 3.7+）

```dart
// 不推荐 —— 忽略 Future
fetchData(); // 发射后不管但意图不明确

// 推荐
unawaited(fetchData()); // 显式发射后不管
await fetchData();      // 正常 await
```

## 导入

- 全局使用 `package:` 导入 —— 跨功能或跨层代码不应使用相对导入（`../`）
- 排序：`dart:` → 外部 `package:` → 内部 `package:`（同一包内）
- 不应保留未使用的导入 —— `dart analyze` 通过 `unused_import` 强制执行

## 代码生成

- 生成的文件（`.g.dart`、`.freezed.dart`、`.gr.dart`）应统一提交或统一 gitignore —— 每个项目选择一种策略
- 不应手动编辑生成的文件
- 生成器注解（`@JsonSerializable`、`@freezed`、`@riverpod` 等）仅放置在规范源文件上
