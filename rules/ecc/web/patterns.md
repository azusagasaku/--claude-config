> 本文是 [common/patterns.md](../common/patterns.md) 的 Web 模式补充，通用设计模式参见原文。

# Web 模式

## 组件组合

### 复合组件

相关 UI 共享状态和交互语义时应使用复合组件：

```tsx
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="settings">Settings</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="overview">...</Tabs.Content>
  <Tabs.Content value="settings">...</Tabs.Content>
</Tabs>
```

- 父组件持有状态
- 子组件通过 context 消费状态
- 对于复杂的小组件，优先使用此模式而非多层 prop 传递

### Render Props / Slots

- 当行为共享但渲染内容需要变化时，使用 render props 或 slot 模式
- 键盘处理、ARIA 属性、焦点管理等逻辑保留在无头层中

### Container / Presentational 分离

- Container 组件负责数据加载和副作用处理
- Presentational 组件接收 props 并负责渲染
- Presentational 组件应保持纯函数化

## 状态管理

以下状态类型应分别管理：

| 关注点 | 推荐工具 |
|---------|---------|
| 服务端状态 | TanStack Query, SWR, tRPC |
| 客户端状态 | Zustand, Jotai, signals |
| URL 状态 | search params, route segments |
| 表单状态 | React Hook Form 或同类方案 |

- 不要将服务端获取的数据重复存入客户端 store
- 可派生的值应直接计算，不创建冗余状态副本

## URL 作为状态载体

以下可共享的状态应持久化在 URL 中：
- 筛选条件
- 排序方式
- 分页参数
- 当前激活的 tab
- 搜索关键词

## 数据获取

### Stale-While-Revalidate

- 立即返回缓存数据
- 后台执行重新验证
- 优先使用现有库，避免自行实现

### 乐观更新

- 保存当前状态快照
- 乐观应用更新结果
- 失败时回滚
- 回滚时必须提供可见的错误反馈

### 并行加载

- 互不依赖的数据应并行请求
- 避免父请求完成才触发子请求的瀑布式加载
- 对可能访问的下一个路由进行预取
