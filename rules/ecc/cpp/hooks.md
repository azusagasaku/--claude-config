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
# C++ 钩子

> 本文件基于 [common/hooks.md](../common/hooks.md) 扩展，补充了 C++ 特有内容。

## 构建钩子

提交 C++ 改动前，按顺序执行以下检查：

```bash
# 格式化检查
clang-format --dry-run --Werror src/*.cpp src/*.hpp

# 静态分析
clang-tidy src/*.cpp -- -std=c++17

# 构建
cmake --build build

# 测试
ctest --test-dir build --output-on-failure
```

## 推荐的 CI 流水线

1. **clang-format** — 格式化检查
2. **clang-tidy** — 静态分析
3. **cppcheck** — 附加静态检查
4. **cmake build** — 编译
5. **ctest** — 带检测器运行测试
