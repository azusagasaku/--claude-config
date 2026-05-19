---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript 安全

> 本文件对 [common/security.md](../common/security.md) 进行扩展，补充 TS/JS 安全相关内容。

## 密钥管理

```typescript
// 禁止：硬编码密钥
const apiKey = "sk-proj-xxxxx"

// 始终使用环境变量
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY 未配置')
}
```

## Agent 支持

- 使用 **security-reviewer** skill 进行全面的安全审计
