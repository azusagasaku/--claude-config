---
paths:
  - "**/*.rs"
---
# Rust 编码风格

> 本文件对 [common/coding-style.md](../common/coding-style.md) 进行扩展，补充 Rust 语言相关内容。

## 格式化

- **rustfmt** 负责格式化 — 提交前必须执行 `cargo fmt`
- **clippy** 负责 lint 检查 — `cargo clippy -- -D warnings`（将警告提升为错误处理）
- 4 空格缩进（rustfmt 默认值，无需修改）
- 每行最大 100 字符（rustfmt 默认值）

## 不可变性

Rust 中变量默认不可变 — 应充分利用这一特性：

- 优先使用 `let` 而非 `let mut`
- 尽量返回新值，避免原地修改
- 函数可能需要条件分配时，考虑使用 `Cow<'_, T>`

```rust
use std::borrow::Cow;

// 推荐 — 默认不可变，返回新值
fn normalize(input: &str) -> Cow<'_, str> {
    if input.contains(' ') {
        Cow::Owned(input.replace(' ', "_"))
    } else {
        Cow::Borrowed(input)
    }
}

// 不推荐 — 不必要地使用可变修改
fn normalize_bad(input: &mut String) {
    *input = input.replace(' ', "_");
}
```

## 命名规范

遵循 Rust 命名惯例：
- 函数、方法、变量、模块、crate 使用 `snake_case`
- 类型、trait、枚举、类型参数使用 `PascalCase`
- 常量和静态变量使用 `SCREAMING_SNAKE_CASE`
- 生命周期：简短的用小写单字母（`'a`、`'de`），复杂场景使用描述性名称（`'input`）

## 所有权与借用

- 优先借用（`&T`）；仅在需要存储或消费值时才获取所有权
- 不应绕过借用检查器随意使用 `clone`，应先理解编译错误的原因再决定方案
- 函数参数中，优先使用 `&str` 而非 `String`，`&[T]` 而非 `Vec<T>`
- 构造函数中确实需要 `String` 时，使用 `impl Into<String>` 以获得更好的灵活性

```rust
// 推荐 — 不需要所有权时使用借用
fn word_count(text: &str) -> usize {
    text.split_whitespace().count()
}

// 推荐 — 通过 Into 在构造函数中获取所有权
fn new(name: impl Into<String>) -> Self {
    Self { name: name.into() }
}

// 不推荐 — &str 已足够却要求 String
fn word_count_bad(text: String) -> usize {
    text.split_whitespace().count()
}
```

## 错误处理

- 使用 `Result<T, E>` 和 `?` 传播错误 — 生产代码中禁止使用 `unwrap()`
- **库代码**：使用 `thiserror` 定义有类型的错误
- **应用代码**：使用 `anyhow` 灵活附加上下文
- 使用 `.with_context(|| format!("failed to ..."))?` 为错误添加说明
- `unwrap()` / `expect()` 仅用于测试及无法到达的分支

```rust
// 推荐 — 库代码使用 thiserror 定义错误
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("读取配置失败: {0}")]
    Io(#[from] std::io::Error),
    #[error("配置格式不正确: {0}")]
    Parse(String),
}

// 推荐 — 应用代码使用 anyhow 处理错误
use anyhow::Context;

fn load_config(path: &str) -> anyhow::Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("读取 {path} 失败"))?;
    toml::from_str(&content)
        .with_context(|| format!("解析 {path} 失败"))
}
```

## 优先使用迭代器而非循环

数据转换时优先使用迭代器链；复杂控制流场景使用循环：

```rust
// 推荐 — 声明式、可组合
let active_emails: Vec<&str> = users.iter()
    .filter(|u| u.is_active)
    .map(|u| u.email.as_str())
    .collect();

// 推荐 — 含提前返回的复杂逻辑使用循环
for user in &users {
    if let Some(verified) = verify_email(&user.email)? {
        send_welcome(&verified)?;
    }
}
```

## 模块组织

按领域而非按类型组织文件：

```text
src/
├── main.rs
├── lib.rs
├── auth/           # 领域模块
│   ├── mod.rs
│   ├── token.rs
│   └── middleware.rs
├── orders/         # 领域模块
│   ├── mod.rs
│   ├── model.rs
│   └── service.rs
└── db/             # 基础设施
    ├── mod.rs
    └── pool.rs
```

## 可见性

- 默认保持私有；模块内部共享使用 `pub(crate)`
- 仅 crate 的公共 API 使用 `pub`
- 在 `lib.rs` 中重新导出公共 API，便于外部使用

## 参考

完整的 Rust 惯用法和模式参见 skill: `rust-patterns`。
