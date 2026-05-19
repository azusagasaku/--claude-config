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
# C++ 测试

> 本文件基于 [common/testing.md](../common/testing.md) 扩展，补充了 C++ 特有内容。

## 测试框架

使用 **GoogleTest**（gtest/gmock）搭配 **CMake/CTest**。

## 运行测试

```bash
cmake --build build && ctest --test-dir build --output-on-failure
```

## 覆盖率

```bash
cmake -DCMAKE_CXX_FLAGS="--coverage" -DCMAKE_EXE_LINKER_FLAGS="--coverage" ..
cmake --build .
ctest --output-on-failure
lcov --capture --directory . --output-file coverage.info
```

## 检测器

CI 中运行测试必须启用检测器：

```bash
cmake -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined" ..
```

## 参考

详细的 C++ 测试模式、TDD 工作流及 GoogleTest/GMock 用法见 skill: `cpp-testing`
