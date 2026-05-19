---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python 安全

> 本文件对 [common/security.md](../common/security.md) 进行扩展，补充 Python 安全相关内容。

## 密钥管理

```python
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.environ["OPENAI_API_KEY"]  # 未配置时将抛出 KeyError，确保缺失的密钥不会被静默忽略
```

## 安全扫描

- 使用 **bandit** 进行静态安全分析：
  ```bash
  bandit -r src/
  ```

## 参考

使用 Django 的项目参见 skill：`django-security`，其中包含 Django 专属的安全指南。
