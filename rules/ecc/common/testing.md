# 测试要求

## 最低测试覆盖率：80%

以下三类测试均属必需：
1. **单元测试** - 独立函数、工具方法、小组件
2. **集成测试** - API 端点、数据库操作
3. **E2E 测试** - 关键用户流程（框架按语言选型）

## 测试驱动开发（TDD）

此流程为强制要求，不可跳过：

1. 先编写测试（RED 阶段）
2. 运行测试 — 应失败
3. 编写最少量代码使测试通过（GREEN 阶段）
4. 运行测试 — 应通过
5. 重构优化（IMPROVE 阶段）
6. 确认覆盖率达到 80% 以上

## 测试失败排查

1. 使用 **tdd-guide** Agent 协助
2. 检查测试隔离性
3. 验证 mock 配置是否正确
4. 优先修复实现代码而非测试（除非测试本身有误）

## Agent 支持

- **tdd-guide** - 开发新功能时主动调用，强制执行先测试后实现的工作流

## 测试结构（AAA 模式）

推荐使用 Arrange-Act-Assert 三段式结构：

```typescript
test('正确计算相似度', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  const vector2 = [0, 1, 0]

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})
```

### 测试命名

命名应清晰表达被测试的行为：

```typescript
test('当没有市场匹配查询时返回空数组', () => {})
test('当 API 密钥缺失时抛出错误', () => {})
test('当 Redis 不可用时回退到子串搜索', () => {})
```
