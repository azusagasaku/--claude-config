---
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---
# Java 钩子

> 本文件基于 [common/hooks.md](../common/hooks.md) 扩展，补充了 Java 特有内容。

## PostToolUse 钩子

在 `~/.claude/settings.json` 中配置：

- **google-java-format**：编辑 `.java` 文件后自动格式化
- **checkstyle**：编辑 Java 文件后自动执行风格检查
- **./mvnw compile** 或 **./gradlew compileJava**：编辑后验证编译是否通过
