---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.service.ts"
  - "**/*.interceptor.ts"
---
# Angular 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 Angular 特定的安全实践。

## XSS 防护

Angular 自动清理绑定值。不应绕过清理器处理用户输入。

```typescript
// 不推荐：绕过清理 — 存在 XSS 风险
this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(userInput);

// 推荐：信任前先显式清理
this.safeHtml = this.sanitizer.sanitize(SecurityContext.HTML, userInput);
```

- 除非有文档记录和审查过的理由，否则不应使用 `bypassSecurityTrust*` 方法
- 不应将不受信任的内容置于 `[innerHTML]` 中 —— 使用 `innerText` 或清理管道
- 不应将 `[href]` 绑定到用户输入 —— Angular 并非在所有场景下都能阻止 `javascript:` URL
- 不应从用户数据拼接模板字符串

## HTTP 安全

仅使用 `HttpClient` —— 除非迫不得已，否则不应使用原生 `fetch()` 或 `XHR`。

```typescript
// 不推荐：绕过拦截器（auth header、错误处理、日志）
const res = await fetch('/api/users');

// 推荐
users$ = this.http.get<User[]>('/api/users');
```

- 通过拦截器附加 auth token —— 不应在单个服务调用中硬编码
- 对 API 响应进行类型化和验证 —— 在边界处将外部数据视为 `unknown`
- 不应记录可能包含 token、PII 或凭证的 HTTP 响应

## 密钥管理

```typescript
// 不推荐：在源码中硬编码密钥
const apiKey = 'sk-live-xxxx';

// 推荐：通过环境注入
import { environment } from '../environments/environment';
const apiKey = environment.apiKey;
```

- 将 `environment.ts` 视为配置形状定义 —— 不应在受版本控制的 environment 文件中存储真实密钥
- 通过 CI/CD 注入生产密钥（环境变量、密钥管理器）

## 路由守卫

每个需要认证或角色限制的路由均应配置守卫。不应仅依赖隐藏 UI 元素进行保护。

```typescript
{
  path: 'admin',
  canMatch: [authGuard, roleGuard('admin')],
  loadChildren: () => import('./admin/admin.routes'),
}
```

对敏感路由使用 `canMatch` —— 当未授权用户访问时，整个路由模块不会被加载。

## SSR 安全

使用 Angular SSR 时：

- 不应通过 `TransferState` 将服务端环境变量暴露给客户端，除非有意公开
- 服务端渲染前清理所有输入 —— 服务端也可能发生基于 DOM 的 XSS
- 不应在服务端使用 `window`、`document`、`localStorage` —— 使用 `isPlatformBrowser` 或通过 `DOCUMENT` token 注入

## 内容安全策略

在服务端配置 CSP header。不应在 `script-src` 中使用 `unsafe-inline`。使用带内联脚本的 SSR 时，通过 Angular 的 CSP 支持使用 nonce。

## Agent 支持

- 使用 **security-reviewer** 技能执行全面的安全审计
