---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.service.ts"
  - "**/*.store.ts"
  - "**/*.routes.ts"
---
# Angular 模式

> 本文件扩展了 [common/patterns.md](../common/patterns.md)，补充 Angular 特定的设计模式。

## 智能组件 / 哑组件分离

智能（容器）组件负责数据获取和状态管理。哑（展示型）组件仅接收输入、发出输出 —— 不注入服务。

```typescript
// 智能组件 — 拥有数据
@Component({ standalone: true, changeDetection: ChangeDetectionStrategy.OnPush })
export class UserPageComponent {
  private userService = inject(UserService);
  user = toSignal(this.userService.getUser(this.userId));
}
```

```html
<!-- 哑组件 — 纯展示 -->
<app-user-card [user]="user()" (select)="onSelect($event)" />
```

## 服务层

服务负责所有数据访问和业务逻辑。组件仅进行委托 —— 组件中不应出现 `HttpClient`。

```typescript
@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
}
```

## 使用 `resource` 处理异步数据

使用 `resource()` 实现响应式异步获取。简单数据加载优先使用它，而非手写 RxJS 流水线：

```typescript
export class UserDetailComponent {
  userId = input.required<string>();

  userResource = resource({
    request: () => ({ id: this.userId() }),
    loader: ({ request }) =>
      firstValueFrom(inject(UserService).getUser(request.id)),
  });
}
```

访问状态：`userResource.value()`、`userResource.isLoading()`、`userResource.error()`、`userResource.reload()`。

## Signal 状态模式

```typescript
// 本地可变状态
count = signal(0);

// 派生（不应重复存储）
doubled = computed(() => this.count() * 2);

// 随源重置的可写派生状态
selectedItem = linkedSignal(() => this.items()[0]);

// 将 Observable 桥接到 signal
users = toSignal(this.userService.getUsers(), { initialValue: [] });
```

不应将派生值单独存储为 signal —— 使用 `computed`。不应使用 `effect` 同步 signals —— 使用 `computed` 或 `linkedSignal`。

## 订阅清理

所有手动订阅均应使用 `takeUntilDestroyed()`。新代码中不应编写手动 `ngOnDestroy` + `Subject` + `takeUntil` 模式。

```typescript
export class UserComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.userService.updates$
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(update => this.handleUpdate(update));
  }
}
```

## 路由

### 路由定义

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'admin',
    canMatch: [authGuard],           // CanMatch 阻止未授权用户加载整个 chunk
    loadChildren: () => import('./admin/admin.routes').then(m => m.ADMIN_ROUTES),
  },
  {
    path: 'users/:id',
    resolve: { user: userResolver },
    component: UserDetailComponent,
  },
];
```

- 当不应让未授权用户加载路由模块时，使用 `canMatch` 而非 `canActivate`
- 使用 `loadChildren` 懒加载所有特性模块
- 使用 `resolve` 预取数据，避免在组件中出现加载状态

### 函数式守卫

```typescript
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  return auth.isAuthenticated()
    ? true
    : inject(Router).createUrlTree(['/login']);
};
```

### 数据解析器

```typescript
export const userResolver: ResolveFn<User> = (route) => {
  return inject(UserService).getUser(route.paramMap.get('id')!);
};
```

### 视图过渡

使用 View Transitions API 实现平滑的路由过渡：

```typescript
// app.config.ts
provideRouter(routes, withViewTransitions())
```

## 依赖注入模式

### 作用域提供者

当服务不应为单例时，在组件或路由级别提供它：

```typescript
@Component({
  providers: [UserEditService],   // 作用域限定在此组件子树
})
export class UserEditComponent {}
```

### `InjectionToken`

```typescript
export const CONFIG = new InjectionToken<AppConfig>('APP_CONFIG');

// 在 providers 中：
{ provide: CONFIG, useValue: appConfig }
{ provide: CONFIG, useFactory: () => loadConfig(), deps: [] }

// 消费：
private config = inject(CONFIG);
```

### `viewProviders` vs `providers`

- `providers`：对组件及其所有内容子组件可用
- `viewProviders`：仅对组件自身视图可用（不含投影内容）

## HTTP 拦截器

使用函数式拦截器（v15+）处理认证、错误处理和重试：

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).token();
  if (!token) return next(req);
  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }));
};
```

在 `app.config.ts` 中注册：

```typescript
provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]))
```

## RxJS 操作符

- `switchMap` — 搜索、导航（取消上一个）
- `mergeMap` — 相互独立的并行请求
- `exhaustMap` — 表单提交（完成前忽略新请求）
- 始终使用 `catchError` 处理错误 —— 避免流静默终止

```typescript
search$ = this.query$.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(q => this.service.search(q).pipe(catchError(() => of([])))),
);
```

## 表单

与项目现有表单策略保持一致。新的 v21+ 应用优先使用 signal forms。

```typescript
// 响应式表单 — 复杂表单的标准方案
export class UserFormComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
  });
}
```

## 渲染策略

- **CSR**（默认）：标准 SPA
- **SSR + Hydration**：`ng add @angular/ssr` — 改善 FCP 和 SEO
- **SSG（预渲染）**：构建时为内容密集型路由生成静态页面

使用 SSR 时不应直接访问 `window`、`document`、`localStorage` —— 使用 `isPlatformBrowser` 或 `DOCUMENT` token。

## 无障碍性

使用 Angular CDK 构建无头、可访问的组件（Accordion、Listbox、Combobox、Menu、Tabs、Toolbar、Tree、Grid）。通过样式化 ARIA 属性管理，避免手动操作：

```css
[aria-selected="true"] { background: var(--color-selected); }
```

## 技能参考

参见技能：`angular-developer`，其中包含 signals、表单、路由、DI、SSR 和无障碍性的深入指南。
