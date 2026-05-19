---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python 模式

> 本文件对 [common/patterns.md](../common/patterns.md) 进行扩展，补充 Python 常用模式。

## Protocol（结构化子类型）

```python
from typing import Protocol

class Repository(Protocol):
    def find_by_id(self, id: str) -> dict | None: ...
    def save(self, entity: dict) -> dict: ...
```

## 使用 Dataclass 作为 DTO

```python
from dataclasses import dataclass

@dataclass
class CreateUserRequest:
    name: str
    email: str
    age: int | None = None
```

## 上下文管理器与生成器

- 管理资源时使用上下文管理器（`with` 语句），确保资源正确释放
- 需要惰性求值或节省内存时使用生成器

## 参考

装饰器、并发、包组织等更全面的模式知识参见 skill：`python-patterns`。
