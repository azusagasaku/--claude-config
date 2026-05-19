---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python 测试

> 本文件对 [common/testing.md](../common/testing.md) 进行扩展，补充 Python 测试相关内容。

## 测试框架

统一使用 **pytest**。

## 覆盖率

```bash
pytest --cov=src --cov-report=term-missing
```

## 测试组织

使用 `pytest.mark` 对测试进行分类，便于按需运行：

```python
import pytest

@pytest.mark.unit
def test_calculate_total():
    ...

@pytest.mark.integration
def test_database_connection():
    ...
```

## 参考

pytest 的详细模式和 fixture 用法参见 skill：`python-testing`。
