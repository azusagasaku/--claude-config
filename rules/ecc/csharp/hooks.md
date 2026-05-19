---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/Directory.Build.props"
  - "**/Directory.Build.targets"
---
# C# 钩子

> 本文件基于 [common/hooks.md](../common/hooks.md) 扩展，补充了 C# 特有内容。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **dotnet format**：编辑 C# 文件后自动格式化并应用分析器修复
- **dotnet build**：编辑后验证 solution 或项目编译状态
- **dotnet test --no-build**：行为变更后重新运行相关测试项目

## Stop 钩子

- 涉及大量 C# 改动的会话结束前，执行一次最终 `dotnet build`
- 修改过 `appsettings*.json` 时发出警告，防止密钥意外提交
