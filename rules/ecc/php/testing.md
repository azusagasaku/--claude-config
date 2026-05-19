---
paths:
  - "**/*.php"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
  - "**/composer.json"
---
# PHP 测试

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 PHP 特定的测试实践。

## 测试框架

默认使用 **PHPUnit**。若项目已配置 **Pest**，新测试应优先使用 Pest 编写；避免在同一项目中混用 PHPUnit 和 Pest，以降低维护复杂度。

## 覆盖率

```bash
vendor/bin/phpunit --coverage-text
# 或
vendor/bin/pest --coverage
```

CI 中优先使用 **pcov** 或 **Xdebug**，覆盖率阈值应写入 CI 配置以强制执行。

## 测试组织

- 将快速的单元测试与框架/数据库集成测试分开执行。
- 使用工厂/构建器生成固定数据，避免手写大量数组。
- HTTP/控制器测试聚焦传输和验证；业务规则放入服务级测试。

## Inertia

若项目使用 Inertia.js，优先使用 `assertInertia` 配合 `AssertableInertia` 验证组件名称和 props，而非使用原始 JSON 断言。

## 参考

全仓库 RED -> GREEN -> REFACTOR 循环参见技能：`tdd-workflow`。
Laravel 测试模式（PHPUnit 和 Pest）参见技能：`laravel-tdd`。
