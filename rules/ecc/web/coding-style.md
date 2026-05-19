> 本文是 [common/coding-style.md](../common/coding-style.md) 的 Web 前端补充，通用规范参见原文。

# Web 编码风格

## 文件组织

按功能/界面区域组织文件，而非按文件类型分类。关联文件应放在同一目录下：

```text
src/
├── components/
│   ├── hero/
│   │   ├── Hero.tsx
│   │   ├── HeroVisual.tsx
│   │   └── hero.css
│   ├── scrolly-section/
│   │   ├── ScrollySection.tsx
│   │   ├── StickyVisual.tsx
│   │   └── scrolly.css
│   └── ui/
│       ├── Button.tsx
│       ├── SurfaceCard.tsx
│       └── AnimatedText.tsx
├── hooks/
│   ├── useReducedMotion.ts
│   └── useScrollProgress.ts
├── lib/
│   ├── animation.ts
│   └── color.ts
└── styles/
    ├── tokens.css
    ├── typography.css
    └── global.css
```

## CSS 自定义属性

设计令牌必须定义为 CSS 变量，禁止在代码中硬编码颜色、字号、间距：

```css
:root {
  --color-surface: oklch(98% 0 0);
  --color-text: oklch(18% 0 0);
  --color-accent: oklch(68% 0.21 250);

  --text-base: clamp(1rem, 0.92rem + 0.4vw, 1.125rem);
  --text-hero: clamp(3rem, 1rem + 7vw, 8rem);

  --space-section: clamp(4rem, 3rem + 5vw, 10rem);

  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
}
```

## 动画属性选择

动画应优先使用对合成器友好的属性：
- `transform`
- `opacity`
- `clip-path`
- `filter`（谨慎使用）

以下属性会触发布局重排，不应作为动画目标：
- `width`
- `height`
- `top`
- `left`
- `margin`
- `padding`
- `border`
- `font-size`

## 语义化 HTML 优先

```html
<header>
  <nav aria-label="Main navigation">...</nav>
</header>
<main>
  <section aria-labelledby="hero-heading">
    <h1 id="hero-heading">...</h1>
  </section>
</main>
<footer>...</footer>
```

有对应语义标签时应直接使用，不要用嵌套的 `div` 代替。

## 命名习惯

- 组件: PascalCase（如 `ScrollySection`、`SurfaceCard`）
- Hooks: `use` 前缀（如 `useReducedMotion`）
- CSS 类名: kebab-case 或遵循工具类命名习惯
- 动画时间线: camelCase，命名应表达意图（如 `heroRevealTl`）
