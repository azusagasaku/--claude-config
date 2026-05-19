# Git 工作流

## 提交消息格式
```
<type>: <description>

<optional body>
```

类型：feat, fix, refactor, docs, test, chore, perf, ci

注意：归属标记已在 ~/.claude/settings.json 中全局禁用。

## Pull Request 工作流

创建 PR 时：
1. 审查全部提交历史，而非仅查看最后一次 commit
2. 运行 `git diff [base-branch]...HEAD` 查看完整变更
3. 编写详尽的 PR 摘要
4. 测试计划中附带 TODO 清单
5. 新分支使用 `-u` 参数推送

> git 操作前的完整流程（规划、TDD、代码审查）参见 [development-workflow.md](./development-workflow.md)。
