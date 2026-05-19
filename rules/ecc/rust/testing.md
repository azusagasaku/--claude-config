---
paths:
  - "**/*.rs"
---
# Rust 测试

> 本文件对 [common/testing.md](../common/testing.md) 进行扩展，补充 Rust 测试相关内容。

## 测试框架

- 使用 `#[test]` 配合 `#[cfg(test)]` 模块编写单元测试
- 使用 **rstest** 进行参数化测试和 fixture
- 使用 **proptest** 进行基于属性的测试
- 使用 **mockall** 进行基于 trait 的模拟
- 使用 `#[tokio::test]` 编写异步测试

## 测试组织

```text
my_crate/
├── src/
│   ├── lib.rs           # 单元测试置于 #[cfg(test)] 模块内
│   ├── auth/
│   │   └── mod.rs       # #[cfg(test)] mod tests { ... }
│   └── orders/
│       └── service.rs   # #[cfg(test)] mod tests { ... }
├── tests/               # 集成测试（每个文件 = 独立的二进制）
│   ├── api_test.rs
│   ├── db_test.rs
│   └── common/          # 共享测试工具
│       └── mod.rs
└── benches/             # Criterion 基准测试
    └── benchmark.rs
```

单元测试置于同一个文件的 `#[cfg(test)]` 模块内。集成测试置于 `tests/` 目录下。

## 单元测试写法

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn creates_user_with_valid_email() {
        let user = User::new("Alice", "alice@example.com").unwrap();
        assert_eq!(user.name, "Alice");
    }

    #[test]
    fn rejects_invalid_email() {
        let result = User::new("Bob", "not-an-email");
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("invalid email"));
    }
}
```

## 参数化测试

```rust
use rstest::rstest;

#[rstest]
#[case("hello", 5)]
#[case("", 0)]
#[case("rust", 4)]
fn test_string_length(#[case] input: &str, #[case] expected: usize) {
    assert_eq!(input.len(), expected);
}
```

## 异步测试

```rust
#[tokio::test]
async fn fetches_data_successfully() {
    let client = TestClient::new().await;
    let result = client.get("/data").await;
    assert!(result.is_ok());
}
```

## 使用 mockall 进行模拟

在生产代码中定义 trait；在测试模块中生成 mock：

```rust
// 生产 trait — 设为 pub 以便集成测试导入
pub trait UserRepository {
    fn find_by_id(&self, id: u64) -> Option<User>;
}

#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::eq;

    mockall::mock! {
        pub Repo {}
        impl UserRepository for Repo {
            fn find_by_id(&self, id: u64) -> Option<User>;
        }
    }

    #[test]
    fn service_returns_user_when_found() {
        let mut mock = MockRepo::new();
        mock.expect_find_by_id()
            .with(eq(42))
            .times(1)
            .returning(|_| Some(User { id: 42, name: "Alice".into() }));

        let service = UserService::new(Box::new(mock));
        let user = service.get_user(42).unwrap();
        assert_eq!(user.name, "Alice");
    }
}
```

## 测试命名

使用能清晰描述场景的命名：
- `creates_user_with_valid_email()`
- `rejects_order_when_insufficient_stock()`
- `returns_none_when_not_found()`

## 覆盖率

- 目标：80%+ 行覆盖率
- 使用 **cargo-llvm-cov** 生成覆盖率报告
- 关注业务逻辑 — 生成代码和 FFI 绑定不计入覆盖率统计

```bash
cargo llvm-cov                       # 摘要
cargo llvm-cov --html                # HTML 报告
cargo llvm-cov --fail-under-lines 80 # 未达阈值则报失败
```

## 测试命令

```bash
cargo test                       # 运行所有测试
cargo test -- --nocapture        # 显示 println 输出
cargo test test_name             # 运行匹配模式的测试
cargo test --lib                 # 仅运行单元测试
cargo test --test api_test       # 运行指定集成测试（tests/api_test.rs）
cargo test --doc                 # 仅运行文档测试
```

## 参考

完整测试模式（属性测试、fixture、Criterion 基准测试等）参见 skill: `rust-testing`。
