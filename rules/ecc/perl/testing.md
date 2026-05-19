---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
  - "**/*.psgi"
  - "**/*.cgi"
---
# Perl 测试

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 Perl 特定的测试实践。

## 测试框架

新项目使用 **Test2::V0**（替代 Test::More）：

```perl
use Test2::V0;

is($result, 42, 'answer is correct');

done_testing;
```

## 运行器

```bash
prove -l t/              # 将 lib/ 加入 @INC
prove -lr -j8 t/         # 递归运行，8 个并行任务
```

始终添加 `-l` 确保 `lib/` 在 `@INC` 中。

## 覆盖率

使用 **Devel::Cover**，目标 80%+：

```bash
cover -test
```

## 模拟

- **Test::MockModule** —— 模拟现有模块的方法。
- **Test::MockObject** —— 从零创建测试替身。

## 常见问题

- 测试文件必须使用 `done_testing` 结尾。
- 不应遗漏 `prove` 的 `-l` 标志。

## 参考

Perl TDD 模式（Test2::V0、prove、Devel::Cover）参见技能：`perl-testing`。
