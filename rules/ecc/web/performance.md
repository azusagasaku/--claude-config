> 本文是 [common/performance.md](../common/performance.md) 的 Web 性能补充，通用部分参见原文。

# Web 性能规则

## Core Web Vitals 目标

| 指标 | 目标值 |
|--------|--------|
| LCP | < 2.5s |
| INP | < 200ms |
| CLS | < 0.1 |
| FCP | < 1.5s |
| TBT | < 200ms |

## 打包体积预算

| 页面类型 | JS 预算（gzip 后） | CSS 预算 |
|-----------|---------------------|------------|
| 落地页 | < 150kb | < 30kb |
| 应用页面 | < 300kb | < 50kb |
| 微网站 | < 80kb | < 15kb |

## 加载策略

1. 在理由充分时将首屏关键 CSS 内联
2. 仅预加载 hero 主图和主要字体
3. 非关键的 CSS 和 JS 延迟加载
4. 体积较大的库使用动态导入

```js
const gsapModule = await import('gsap');
const { ScrollTrigger } = await import('gsap/ScrollTrigger');
```

## 图片优化

- 必须明确设置 `width` 和 `height`
- 仅对 hero 主媒体使用 `loading="eager"` 并配合 `fetchpriority="high"`
- 首屏以下的资源统一使用 `loading="lazy"`
- 优先选择 AVIF 或 WebP 格式，同时准备降级方案
- 源图片尺寸不应远超实际渲染尺寸

## 字体加载

- 除非有充分理由，最多使用两种字体家族
- 统一设置 `font-display: swap`
- 优先使用子集化
- 仅预加载真正关键的字体粗细/样式

## 动画性能

- 仅使用合成器友好属性做动画
- `will-change` 仅在必要时使用，用后及时移除
- 简单过渡优先使用 CSS
- JS 动画使用 `requestAnimationFrame` 或可靠的动画库
- 禁止在 scroll 事件中执行重操作；使用 IntersectionObserver 或可靠的库处理

## 性能自查清单

- [ ] 所有图片设置了明确的尺寸
- [ ] 无意外阻塞渲染的资源
- [ ] 动态内容未引起布局偏移
- [ ] 动效全部使用合成器友好属性
- [ ] 第三方脚本使用 async/defer 加载且仅在必要时加载
