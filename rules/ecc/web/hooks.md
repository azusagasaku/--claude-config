> 本文是 [common/hooks.md](../common/hooks.md) 的 Web 补充，Hook 通用概念参见原文。

# Web Hooks

## 推荐的 PostToolUse Hooks

优先使用项目本地工具，不要绑定到远程一次性包执行。

### 保存时自动格式化

编辑后使用项目自身的格式化入口：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm prettier --write \"$FILE_PATH\"",
        "description": "Format edited frontend files"
      }
    ]
  }
}
```

使用 `yarn prettier` 或 `npm exec prettier --` 同样可行，只要依赖来自项目本地即可。

### Lint 检查

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm eslint --fix \"$FILE_PATH\"",
        "description": "Run ESLint on edited frontend files"
      }
    ]
  }
}
```

### 类型检查

使用 `--incremental` 让后续检查复用 `.tsbuildinfo`，在未修改的代码上仅需 1-3 秒，而非每次从头检查耗费 30-60 秒。用 `timeout` 包裹，防止 tsc 卡死时进程堆积——编辑触发速度快于 tsc 执行速度时此问题极易发生。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "timeout 60 pnpm tsc --noEmit --pretty false --incremental --tsBuildInfoFile node_modules/.cache/tsc-hook.tsbuildinfo",
        "description": "Type-check after frontend edits (incremental + timeout-capped)"
      }
    ]
  }
}
```

**两个参数必须同时使用的原因：**
- 缺少 `--incremental`，每次编辑都将整个项目从头检查。在一个实际的 Next.js 项目上，编辑间隔 5-10 秒加上 tsc 运行时间 30-60 秒，几轮后就会累积多个并发 tsc 进程。
- 缺少 `timeout`，卡住的 tsc（例如传递依赖变更、递归类型导致类型检查器停滞）永远不会自行退出，父 shell 退出后成为孤儿进程。
- `--tsBuildInfoFile` 必须显式指定，因为 `--noEmit` 默认不写入 buildinfo，不指定则增量模式不生效。

在 Windows 上没有 GNU coreutils 的环境中，将 `timeout 60` 替换为 PowerShell 包装脚本，或借助 Stop/SessionEnd hook 清理残留的 tsc 进程。

### CSS Lint

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm stylelint --fix \"$FILE_PATH\"",
        "description": "Lint edited stylesheets"
      }
    ]
  }
}
```

## PreToolUse Hooks

### 文件大小拦截

在写入前判断内容是否超出上限，检查的是工具输入内容而非尚未写入的文件：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const c=i.tool_input?.content||'';const lines=c.split('\\n').length;if(lines>800){console.error('[Hook] BLOCKED: File exceeds 800 lines ('+lines+' lines)');console.error('[Hook] Split into smaller modules');process.exit(2)}console.log(d)})\"",
        "description": "Block writes that exceed 800 lines"
      }
    ]
  }
}
```

## Stop Hooks

### 最终构建验证

```json
{
  "hooks": {
    "Stop": [
      {
        "command": "pnpm build",
        "description": "Verify the production build at session end"
      }
    ]
  }
}
```

## 执行顺序

推荐顺序：
1. 格式化
2. Lint 检查
3. 类型检查
4. 构建验证
