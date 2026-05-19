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
# C++ 安全

> 本文件基于 [common/security.md](../common/security.md) 扩展，补充了 C++ 特有内容。

## 内存安全

- 禁止使用裸 `new`/`delete` —— 使用智能指针
- 禁止使用 C 风格数组 —— 使用 `std::array` 或 `std::vector`
- 禁止使用 `malloc`/`free` —— 使用 C++ 分配方式
- `reinterpret_cast` 仅在必要时使用

## 缓冲区溢出

- 使用 `std::string` 替代 `char*`
- 安全检查场景使用 `.at()` 进行边界检查
- 禁止使用 `strcpy`、`strcat`、`sprintf` —— 使用 `std::string` 或 `fmt::format`

## 未定义行为

- 变量必须初始化
- 避免有符号整数溢出
- 禁止解引用空指针或悬空指针
- CI 中启用检测器：
  ```bash
  cmake -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined" ..
  ```

## 静态分析

- 使用 **clang-tidy** 自动检查：
  ```bash
  clang-tidy --checks='*' src/*.cpp
  ```
- 使用 **cppcheck** 附加检查：
  ```bash
  cppcheck --enable=all src/
  ```

## 参考

详细的安全指南见 skill: `cpp-coding-standards`
