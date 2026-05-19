> 本文是 [common/security.md](../common/security.md) 的 Web 安全补充，通用安全规范参见原文。

# Web 安全规则

## 内容安全策略（CSP）

生产环境必须配置 CSP。

### 基于 Nonce 的 CSP

为每个请求生成独立的 nonce，禁止使用 `'unsafe-inline'` ：

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{RANDOM}' https://cdn.jsdelivr.net;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://*.example.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
```

上述域名需根据项目实际情况修改，不要直接复制使用。

## XSS 防护

- 严禁注入未经消毒的 HTML
- 避免使用 `innerHTML` 和 `dangerouslySetInnerHTML`，除非先经过消毒处理
- 模板中的动态值必须转义
- 确实需要展示用户 HTML 时，使用经过验证的本地消毒库处理

## 第三方脚本

- 全部异步加载
- 从 CDN 加载时添加 SRI
- 每季度执行一次审计
- 关键依赖优先自托管

## HTTPS 和响应头

```text
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## 表单

- 会修改数据的表单必须启用 CSRF 防护
- 提交端点统一添加速率限制
- 前后端均需校验
- 优先使用蜜罐或轻量反滥用方案，而非直接部署重型 CAPTCHA
