---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---
# Rust Hooks

> 本文件对 [common/hooks.md](../common/hooks.md) 进行扩展，补充 Rust 的 hook 配置。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置：

- **cargo fmt**：编辑 `.rs` 文件后自动格式化
- **cargo clippy**：编辑 Rust 文件后执行 lint 检查
- **cargo check**：修改代码后快速验证编译状态（比 `cargo build` 更快，适合日常开发使用）
