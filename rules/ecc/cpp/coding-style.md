---
paths:
  - "**/*.cpp"
  - "**/*.hpp"
  - "**/*.cc"
  - "**/*.hh"
  - "**/*.cxx"
  - "**/*.h"
  - "**/CMakeLists.txt"
---
# C++ 编码风格

> 本文件基于 [common/coding-style.md](../common/coding-style.md) 扩展，补充了 C++ 特有内容。

## 现代 C++（C++17/20/23）

- 优先使用现代 C++ 特性，避免 C 风格写法
- 类型可从上下文推断时使用 `auto`
- 编译期常量使用 `constexpr`
- 使用结构化绑定：`auto [key, value] = map_entry;`

## 资源管理

- **全面使用 RAII** —— 禁止手动 `new`/`delete`
- 独占所有权使用 `std::unique_ptr`
- 仅在确实需要共享所有权时使用 `std::shared_ptr`
- 使用 `std::make_unique` / `std::make_shared`，禁止裸调 `new`

## 命名约定

- 类型/类：`PascalCase`
- 函数/方法：`snake_case` 或 `camelCase`（遵循项目约定）
- 常量：`kPascalCase` 或 `UPPER_SNAKE_CASE`
- 命名空间：全小写
- 成员变量：`snake_case_`（末尾下划线）或 `m_` 前缀

## 格式化

- 使用 **clang-format** 自动管理格式
- 提交前执行 `clang-format -i <file>`

## 参考

全面的 C++ 编码标准与指南见 skill: `cpp-coding-standards`
