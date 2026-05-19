---
paths:
  - "**/*.fs"
  - "**/*.fsx"
  - "**/*.fsproj"
  - "**/*.sln"
  - "**/*.slnx"
  - "**/Directory.Build.props"
  - "**/Directory.Build.targets"
---
# F# 钩子系统

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 F# 特定的钩子配置。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **fantomas**：自动格式化编辑过的 F# 文件
- **dotnet build**：编辑后验证解决方案或项目仍可编译
- **dotnet test --no-build**：行为变更后重新运行最接近的相关测试项目

## Stop 钩子

- 涉及大量 F# 更改的会话结束前，执行一次最终的 `dotnet build`
- 对修改过的 `appsettings*.json` 文件发出警告，防止密钥被提交
