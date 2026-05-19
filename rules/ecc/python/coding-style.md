---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python 编码风格

> 本文件对 [common/coding-style.md](../common/coding-style.md) 进行扩展，补充 Python 语言相关内容。

## 标准

- 遵循 **PEP 8** 规范
- 所有函数签名均应添加 **类型注解**

## 不可变性

优先使用不可变数据结构，避免意外副作用：

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    name: str
    email: str

from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float
```

## 格式化

- 使用 **black** 进行代码格式化
- 使用 **isort** 对 import 进行排序
- 使用 **ruff** 进行 lint 检查

## 参考

更多 Python 惯用法和模式参见 skill：`python-patterns`。
