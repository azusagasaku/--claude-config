---
paths:
  - "**/*.ets"
  - "**/*.ts"
  - "**/module.json5"
  - "**/oh-package.json5"
---
# HarmonyOS / ArkTS 钩子

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 HarmonyOS / ArkTS 特定的钩子配置。

## 构建命令

### HAP 包构建

```bash
# 构建 HAP 包（全局 hvigor 环境）
hvigorw assembleHap -p product=default

# 构建指定模块
hvigorw assembleHap -p module=entry -p product=default

# 清理构建
hvigorw clean
```

### DevEco Studio CLI

```bash
# 检查项目结构
hvigorw --version

# 安装依赖
ohpm install

# 更新依赖
ohpm update
```

## 推荐的 PostToolUse 钩子

### 编辑 .ets/.ts 文件后

执行 hvigor 构建以检查 ArkTS 编译错误：

```json
{
  "type": "PostToolUse",
  "matcher": {
    "tool": ["Edit", "Write"],
    "filePath": ["**/*.ets", "**/*.ts"]
  },
  "hooks": [
    {
      "command": "hvigorw assembleHap -p product=default 2>&1 | tail -20",
      "async": true,
      "timeout": 60000
    }
  ]
}
```

### 编辑 module.json5 后

验证权限和能力声明：

```json
{
  "type": "PostToolUse",
  "matcher": {
    "tool": "Edit",
    "filePath": "**/module.json5"
  },
  "hooks": [
    {
      "command": "echo '[HarmonyOS] module.json5 modified - verify permissions and abilities'",
      "async": false
    }
  ]
}
```

### 编辑 oh-package.json5 后

重新安装依赖：

```json
{
  "type": "PostToolUse",
  "matcher": {
    "tool": "Edit",
    "filePath": "**/oh-package.json5"
  },
  "hooks": [
    {
      "command": "ohpm install 2>&1 | tail -10",
      "async": true,
      "timeout": 30000
    }
  ]
}
```

## PreToolUse 钩子

### V1 装饰器守卫

当代码中出现 V1 状态管理装饰器时发出提醒：

```json
{
  "type": "PreToolUse",
  "matcher": {
    "tool": ["Write", "Edit"],
    "filePath": "**/*.ets"
  },
  "hooks": [
    {
      "command": "echo '[HarmonyOS] Reminder: Use @ComponentV2 / @Local / @Param - V1 decorators (@State, @Prop, @Link) are prohibited'"
    }
  ]
}
```

## 验证清单

每次实现周期后，验证以下内容：

- [ ] `hvigorw assembleHap` 无错误完成
- [ ] 新增或修改的 `.ets` 文件中无 V1 装饰器
- [ ] 新增或修改的文件中无 `@ohos.router` 导入
- [ ] 所有 API 权限已在 `module.json5` 中声明
- [ ] 所有依赖已在 `oh-package.json5` 中列出
- [ ] 资源字符串已添加到所有国际化目录中
- [ ] 新增颜色资源已提供深色主题配色
