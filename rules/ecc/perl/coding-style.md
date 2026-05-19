---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
  - "**/*.psgi"
  - "**/*.cgi"
---
# Perl 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 Perl 特定的编码约定。

## 标准

- 始终使用 `use v5.36`（自动启用 `strict`、`warnings`、`say`、子程序签名）。
- 使用子程序签名，不应再手动解构 `@_`。
- 优先使用 `say` 而非带显式换行符的 `print`。

## 不可变性

- 所有属性使用 **Moo**，配合 `is => 'ro'` 和 `Types::Standard`。
- 不应直接操作 blessed 哈希引用，应使用 Moo/Moose 访问器。
- **面向对象覆盖说明**：计算得出的只读值使用 Moo `has` 属性配合 `builder` 或 `default` 是允许的。

## 格式化

使用 **perltidy**，按以下配置：

```
-i=4    # 4 空格缩进
-l=100  # 100 字符行宽
-ce     # 紧凑 else
-bar    # 起始大括号始终靠右
```

## 代码检查

使用 **perlcritic**，严重级别设为 3，主题包含：`core`、`pbp`、`security`。

```bash
perlcritic --severity 3 --theme 'core || pbp || security' lib/
```

## 参考

现代 Perl 惯用法和最佳实践参见技能：`perl-patterns`。
