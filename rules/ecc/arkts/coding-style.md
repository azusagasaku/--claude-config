---
paths:
  - "**/*.ets"
  - "**/*.ts"
  - "**/module.json5"
  - "**/oh-package.json5"
  - "**/build-profile.json5"
---
# HarmonyOS / ArkTS 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 HarmonyOS / ArkTS 特定的编码约定。

## ArkTS 语言约束

ArkTS 是 TypeScript 的一个严格、静态类型的子集。违反以下任意约束将导致**编译失败**。

### 类型系统

- 不允许 `any` 或 `unknown` 类型 —— 必须使用显式类型。
- 不允许索引访问类型 —— 直接使用类型名称。
- 不允许条件类型别名或 `infer` 关键字。
- 不允许交叉类型 —— 用继承。
- 不允许映射类型 —— 用类和常规写法。
- 不允许 `typeof` 用于类型注解 —— 使用显式类型声明。
- 不允许 `as const` 断言 —— 使用显式类型注解。
- 不允许结构化类型 —— 用继承、接口或类型别名。
- 除 `Partial`、`Required`、`Readonly`、`Record` 外，避免使用 TypeScript 工具类型。
- 对于 `Record<K, V>`，索引表达式类型是 `V | undefined`。
- `catch` 子句中省略类型注解（ArkTS 不支持 `any`/`unknown`）。

### 函数与类

- 不允许函数表达式 —— 用箭头函数。
- 不允许嵌套函数 —— 用 lambda。
- 不允许生成器函数 —— 使用 `async`/`await` 实现多任务处理。
- 不允许 `Function.apply`、`Function.call`、`Function.bind` —— 用传统 OOP 方式处理 `this`。
- 不允许构造函数类型表达式 —— 用 lambda。
- 不允许在接口或对象类型中使用构造函数签名 —— 用方法或类。
- 不允许在构造函数中声明类字段 —— 应在类体中声明。
- 不允许在独立函数或静态方法中使用 `this` —— 仅限实例方法中使用。
- 不允许 `new.target`。
- 不允许确定赋值断言（`let v!: T`）—— 应在声明时直接初始化。
- 不允许类字面量 —— 引入具名类类型。
- 不允许将类作为对象使用（赋值给变量）—— 类声明引入的是类型不是值。
- 每个类仅允许一个静态块 —— 应将静态语句合并至一处。

### 对象与属性访问

- 不允许动态字段声明或 `obj["field"]` 访问 —— 用 `obj.field` 语法。
- 不允许 `delete` 运算符 —— 应使用可空类型，以 `null` 标记缺失。
- 不允许原型赋值 —— 用类和接口。
- 不允许 `in` 运算符 —— 用 `instanceof`。
- 不允许重新赋值对象方法 —— 用包装函数或继承。
- 不允许 `Symbol()` API（`Symbol.iterator` 除外）。
- 不允许 `globalThis` 或全局作用域 —— 用显式模块导出/导入。
- 不允许将命名空间作为对象使用 —— 应使用类或模块。
- 不允许命名空间内写语句 —— 用函数。

### 解构与展开

- 不允许解构赋值或变量声明 —— 用中间对象和逐字段访问。
- 不允许解构参数声明 —— 应直接传递参数并手动赋值给局部变量。
- 展开运算符仅可将数组（或数组派生类）展开到剩余参数或数组字面量中。

### 模块与导入

- 不允许 `require()` —— 用常规 `import` 语法。
- 不允许 `export = ...` —— 应使用标准的 export/import。
- 不允许导入断言 —— ArkTS 的导入是编译期的。
- 不允许 UMD 模块。
- 模块名里不允许通配符。
- 所有 `import` 语句必须写在所有其他语句前面。
- TypeScript 代码库不能通过 import 依赖 ArkTS 代码库（不支持反向引用）。

### 其他限制

- 不允许 `var` —— 用 `let`。
- 不允许 `for...in` 循环 —— 数组用常规 `for` 循环。
- 不允许 `with` 语句。
- 不允许 JSX 表达式。
- 不允许 `#` 私有标识符 —— 用 `private` 关键字。
- 不允许声明合并（类、接口、枚举）—— 应将定义合并。
- 不允许索引签名 —— 用数组。
- 逗号运算符仅允许在 `for` 循环中使用。
- 一元运算符 `+`、`-`、`~` 只能用于数值类型（不允许隐式字符串转换）。
- 枚举成员：只允许同类型的编译期表达式用于显式初始化。
- 函数返回类型推断受限 —— 调用返回类型被省略的函数时应显式写出返回类型。

### 对象字面量

- 只有编译器能推断出对应类或接口时才支持。
- 不支持的情况：`any`/`Object`/`object` 类型、带方法的类/接口、带参数化构造函数的类、带 `readonly` 字段的类。

## 命名约定

- 变量 / 函数：`camelCase`（比如 `getUserInfo`、`goodsList`）
- 类 / 接口：`PascalCase`（比如 `UserViewModel`、`IGoodsModel`）
- 常量：`UPPER_SNAKE_CASE`（比如 `MAX_PAGE_SIZE`、`COLOR_PRIMARY`）
- 文件名：组件用 `PascalCase`（比如 `HomePage.ets`），工具函数用 `camelCase`

## 格式化

- 字符串优先使用双引号。
- 语句末尾添加分号。
- 禁止使用 `var` —— 优先使用 `const`，其次使用 `let`。
- 所有方法、参数、返回值必须有完整的类型注解。

## 文件组织

- 组件文件（`.ets`）：每个文件一个 `@ComponentV2`。
- ViewModel 文件：每个文件一个 ViewModel 类。
- Model 文件：相关的数据模型可以共享一个文件。
- 文件控制在 400 行以内；接近 800 行的文件应提取辅助函数。

## 注释

- 文件头：`@file`（文件用途）+ `@author`（开发者），前提是项目已使用文件头约定。
- 公共方法：JSDoc 配合 `@param`、`@returns`；复杂方法加 `@example`。
- 与项目现有的文档语言保持一致；除非仓库统一使用中文注释，否则使用英文。

## 错误处理

```typescript
// 用 try/catch 配合正确的错误处理
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  hilog.error(0x0000, 'TAG', 'Operation failed: %{public}s', error)
  throw new Error('User-friendly error message')
}
```

## 不可变性

遵循通用的不可变性原则 —— 创建新对象而不是修改现有的：

```typescript
// 错误：直接修改
function updateUser(user: UserModel, name: string): UserModel {
  user.name = name  // 直接修改
  return user
}

// 正确：不可变 —— 创建新实例
function updateUser(user: UserModel, name: string): UserModel {
  const updated = new UserModel()
  updated.id = user.id
  updated.name = name
  updated.email = user.email
  return updated
}
```
