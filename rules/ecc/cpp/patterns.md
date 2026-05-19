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
# C++ 模式

> 本文件基于 [common/patterns.md](../common/patterns.md) 扩展，补充了 C++ 特有内容。

## RAII（资源获取即初始化）

将资源生命周期与对象生命周期绑定：

```cpp
class FileHandle {
public:
    explicit FileHandle(const std::string& path) : file_(std::fopen(path.c_str(), "r")) {}
    ~FileHandle() { if (file_) std::fclose(file_); }
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
private:
    std::FILE* file_;
};
```

## 五法则 / 零法则

- **零法则**：尽可能不自定义析构函数、拷贝/移动构造、赋值运算符，交由编译器处理
- **五法则**：一旦定义了析构/拷贝构造/拷贝赋值/移动构造/移动赋值中任意一个，则五个全部显式定义

## 值语义

- 小型/平凡类型按值传递
- 大型类型使用 `const&` 传递
- 返回值使用值返回（编译器自动进行 RVO/NRVO 优化）
- sink 参数使用移动语义

## 错误处理

- 异常情况抛出异常
- 可能不存在的值使用 `std::optional`
- 预期内的失败使用 `std::expected`（C++23）或等效 result 类型

## 参考

全面的 C++ 模式与反模式见 skill: `cpp-coding-standards`
