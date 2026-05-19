> 本文是 [common/testing.md](../common/testing.md) 的 Web 测试补充，通用测试规范参见原文。

# Web 测试规则

## 测试优先级

### 1. 视觉回归

- 关键断点截图：320, 768, 1024, 1440
- 重点测试 hero 区域、滚动叙事区域及各类有意义的交互状态
- 视觉密集型项目使用 Playwright 截图
- 如果同时存在浅色和暗色主题，两者均需测试

### 2. 无障碍

- 运行自动化无障碍检查
- 测试键盘导航是否正常
- 验证 reduced-motion 行为
- 验证颜色对比度

### 3. 性能

- 对关键页面运行 Lighthouse 或同等工具
- 确保达到 [performance.md](performance.md) 中列出的 CWV 目标

### 4. 跨浏览器

- 至少覆盖 Chrome、Firefox、Safari
- 测试滚动、动效及降级行为

### 5. 响应式

- 测试分辨率：320, 375, 768, 1024, 1440, 1920
- 确认无内容溢出
- 确认触摸交互正常

## E2E 测试示例

```ts
import { test, expect } from '@playwright/test';

test('landing hero loads', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toBeVisible();
});
```

- 避免使用 timeout 做断言，容易产生不稳定测试
- 优先使用确定性等待

## 单元测试

- 工具函数、数据转换、自定义 hooks 应编写对应测试
- 对于视觉权重较大的组件，视觉回归测试通常比标记断言更有价值
- 视觉回归测试是对覆盖率目标的补充，而非替代
