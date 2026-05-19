---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript 编码风格

> 本文件对 [common/coding-style.md](../common/coding-style.md) 进行扩展，补充 TS/JS 语言相关内容。

## 类型与接口

为公共 API、共享模型、组件 props 添加显式类型标注，提升可读性与复用性。

### 公共 API

- 导出函数、共享工具函数、公共类方法均应标注参数类型和返回值类型
- 局部变量类型含义明确时，交由 TypeScript 自动推断即可
- 重复出现的对象形状应抽取为命名类型或接口，避免内联定义

```typescript
// 错误：导出函数缺少明确的类型标注
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}

// 正确：公共 API 使用明确的类型标注
interface User {
  firstName: string
  lastName: string
}

export function formatUser(user: User): string {
  return `${user.firstName} ${user.lastName}`
}
```

### 接口 vs. 类型别名

- 需要扩展或实现的 object 形状，使用 `interface`
- 联合类型、交叉类型、元组、映射类型、工具类型，使用 `type`
- 优先使用字符串字面量联合类型；仅在互操作性必需时使用 `enum`

```typescript
interface User {
  id: string
  email: string
}

type UserRole = 'admin' | 'member'
type UserWithRole = User & {
  role: UserRole
}
```

### 禁止使用 `any`

- 应用代码中禁止使用 `any`
- 外部或不受信任的输入使用 `unknown`，然后安全地进行类型收窄
- 值的类型取决于调用方的，使用泛型

```typescript
// 错误：any 破坏了类型安全
function getErrorMessage(error: any) {
  return error.message
}

// 正确：unknown 强制进行安全的类型收窄
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}
```

### React Props

- 使用命名的 `interface` 或 `type` 定义组件 props
- 回调 props 应添加明确的类型标注
- 通常避免使用 `React.FC`，除非有明确的理由

```typescript
interface User {
  id: string
  email: string
}

interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

function UserCard({ user, onSelect }: UserCardProps) {
  return <button onClick={() => onSelect(user.id)}>{user.email}</button>
}
```

### JavaScript 文件

- 在 `.js` 和 `.jsx` 文件中，若类型标注能提升可读性且暂未迁移至 TypeScript，可使用 JSDoc 提供类型信息
- 确保 JSDoc 描述与实际运行时行为一致

```javascript
/**
 * @param {{ firstName: string, lastName: string }} user
 * @returns {string}
 */
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}
```

## 不可变性

使用展开运算符进行不可变更新：

```typescript
interface User {
  id: string
  name: string
}

// 错误：直接修改原对象
function updateUser(user: User, name: string): User {
  user.name = name // 直接修改原对象
  return user
}

// 正确：不可变方式
function updateUser(user: Readonly<User>, name: string): User {
  return {
    ...user,
    name
  }
}
```

## 错误处理

使用 async/await 配合 try-catch，安全地对 unknown 类型的错误进行收窄：

```typescript
interface User {
  id: string
  email: string
}

declare function riskyOperation(userId: string): Promise<User>

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}

const logger = {
  error: (message: string, error: unknown) => {
    // 替换为项目所使用的生产级日志库（如 pino 或 winston）
  }
}

async function loadUser(userId: string): Promise<User> {
  try {
    const result = await riskyOperation(userId)
    return result
  } catch (error: unknown) {
    logger.error('Operation failed', error)
    throw new Error(getErrorMessage(error))
  }
}
```

## 输入验证

使用 Zod 进行基于 schema 的验证，类型直接从 schema 推导：

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

type UserInput = z.infer<typeof userSchema>

const validated: UserInput = userSchema.parse(input)
```

## Console.log

- 生产代码中禁止保留 `console.log`
- 日志输出应使用生产级日志库（如 pino 或 winston）
- 可配置 hook 自动检测，详见 hooks 配置
