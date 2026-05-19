# Agent 编排

## 可用 Agent

所有 Agent 位于 `~/.claude/agents/` 目录下：

| Agent | 用途 | 使用场景 |
|-------|---------|-------------|
| planner | 实现方案规划 | 复杂功能、重构 |
| architect | 系统设计 | 架构决策 |
| tdd-guide | 测试驱动开发 | 新功能、Bug 修复 |
| code-reviewer | 代码审查 | 代码编写完成后 |
| security-reviewer | 安全分析 | 提交前 |
| build-error-resolver | 修复构建错误 | 构建失败时 |
| e2e-runner | E2E 测试 | 关键用户流程 |
| refactor-cleaner | 清理死代码 | 代码维护 |
| doc-updater | 文档 | 更新文档 |
| rust-reviewer | Rust 代码审查 | Rust 项目 |
| harmonyos-app-resolver | HarmonyOS 应用开发 | HarmonyOS/ArkTS 项目 |

## 主动调度 Agent

以下场景无需等待用户指令，直接调用：
1. 复杂功能需求 — 使用 **planner** Agent
2. 代码编写/修改完成 — 使用 **code-reviewer** Agent
3. Bug 修复或新增功能 — 使用 **tdd-guide** Agent
4. 架构决策 — 使用 **architect** Agent

## 并行执行

互不依赖的任务应并行处理：

```markdown
# 正确：并行执行
同时启动 3 个 Agent：
1. Agent 1：auth 模块安全分析
2. Agent 2：缓存系统性能审查
3. Agent 3：工具函数类型检查

# 错误：无必要的顺序执行
先 Agent 1，再 Agent 2，再 Agent 3
```

## 多角度分析

复杂问题由不同角色的子 Agent 各自主导审查：
- 事实审查员
- 高级工程师
- 安全专家
- 一致性审查员
- 冗余检查员
