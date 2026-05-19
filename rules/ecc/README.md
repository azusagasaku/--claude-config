# Rules
## 结构

规则分为 **common（通用层）** 和 **语言特定层**：

```
rules/
├── common/          # 语言无关的通用原则（必须安装）
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md
│   ├── performance.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── agents.md
│   └── security.md
├── typescript/      # TypeScript/JavaScript 特定
├── angular/         # Angular 特定
├── python/          # Python 特定
├── golang/          # Go 特定
├── web/             # Web 与前端特定
├── swift/           # Swift 特定
├── php/             # PHP 特定
├── ruby/            # Ruby / Rails 特定
└── arkts/           # HarmonyOS / ArkTS 特定
```

- **common/** 包含通用原则，不包含任何特定语言的代码示例。
- **语言目录** 在 common 规则的基础上扩展，添加框架特定的模式、工具和代码示例。每个文件都引用其对应的 common 文件。

## 安装

### 方式一：安装脚本（推荐）

```bash
# 安装 common + 一个或多个语言规则集
./install.sh typescript
./install.sh angular
./install.sh python
./install.sh golang
./install.sh web
./install.sh swift
./install.sh php
./install.sh ruby
./install.sh arkts

# 可同时安装多个语言
./install.sh typescript python
```

### 方式二：手动安装

> **重要：** 须复制整个目录，不要使用 `/*` 展平目录。
> Common 与语言目录中存在同名文件，
> 展平会导致语言特定文件覆盖 common 规则，
> 并破坏 `../common/` 相对引用。
>
> 用户级别的 Claude 安装请使用以下 ECC 命名空间。
> 直接展平的包级路径可能与其他非 ECC 规则包冲突，且不符合主 README 指导。

```bash
# 创建 ECC 规则命名空间
mkdir -p ~/.claude/rules/ecc

# 安装 common 规则（所有项目均需要）
cp -r rules/common ~/.claude/rules/ecc/

# 根据项目技术栈安装对应语言规则
cp -r rules/typescript ~/.claude/rules/ecc/
cp -r rules/angular ~/.claude/rules/ecc/
cp -r rules/python ~/.claude/rules/ecc/
cp -r rules/golang ~/.claude/rules/ecc/
cp -r rules/web ~/.claude/rules/ecc/
cp -r rules/swift ~/.claude/rules/ecc/
cp -r rules/php ~/.claude/rules/ecc/
cp -r rules/ruby ~/.claude/rules/ecc/
cp -r rules/arkts ~/.claude/rules/ecc/

# 注意：请根据实际项目需求配置，以上仅为参考示例。
```

项目局部规则可在项目根目录下使用相同的命名空间：

```bash
mkdir -p .claude/rules/ecc
cp -r rules/common .claude/rules/ecc/
cp -r rules/typescript .claude/rules/ecc/
```

## Rules 与 Skills 的区别

- **Rules** 定义广泛适用的标准、约定和检查清单（如"测试覆盖率 80%"、"不得硬编码密钥"）。
- **Skills**（位于 `skills/` 目录）提供针对特定任务的深度参考材料（如 `python-patterns`、`golang-testing`）。

语言规则文件在合适的位置引用相关 skills。Rules 告诉你*做什么*；Skills 告诉你*怎么做*。

## 添加新语言

以添加 `rust/` 为例：

1. 创建 `rules/rust/` 目录
2. 添加扩展 common 规则的文件：
   - `coding-style.md` — 格式化工具、惯用写法、错误处理模式
   - `testing.md` — 测试框架、覆盖率工具、测试组织方式
   - `patterns.md` — Rust 特定设计模式
   - `hooks.md` — 用于格式化器、检查器、类型检查器的 PostToolUse hooks
   - `security.md` — 密钥管理、安全扫描工具
3. 每个文件应以以下内容开头：
   ```
   > 本文件扩展 [common/xxx.md](../common/xxx.md)，添加了 <语言名> 的特定内容。
   ```
4. 引用已有 skills（如存在），否则在 `skills/` 下创建新 skills。

对于 `web/` 等非语言领域，当可复用的领域特定指导足够丰富时，遵循相同的分层模式。

## 规则优先级

当语言特定规则与 common 规则冲突时，**语言特定规则优先**（具体覆盖通用）。这遵循分层配置模式（类似于 CSS 特异性或 `.gitignore` 优先级机制）。

- `rules/common/` 定义适用于所有项目的通用默认值。
- `rules/golang/`、`rules/python/`、`rules/swift/`、`rules/php/`、`rules/typescript/` 等在语言习惯不同时覆盖默认值。

### 示例

`common/coding-style.md` 默认推荐不可变性原则。而 `golang/coding-style.md` 可覆盖此规则：

> Go 惯用写法使用指针接收器修改结构体 —— 通用原则参见 [common/coding-style.md](../common/coding-style.md)，但此处遵循 Go 惯用写法。

### 带有覆盖说明的 common 规则

`rules/common/` 中可能被语言特定规则覆盖的条目会标注：

> **语言注意**：此规则可能被语言特定规则覆盖，适用于该语言不以此模式为惯用写法的情况。
