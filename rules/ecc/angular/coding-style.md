---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.service.ts"
  - "**/*.directive.ts"
  - "**/*.pipe.ts"
  - "**/*.guard.ts"
  - "**/*.resolver.ts"
  - "**/*.module.ts"
---
# Angular 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 Angular 特定的编码约定。

## 版本确认

编码前应确认项目的 Angular 版本。不同主版本之间存在显著差异。执行 `ng version` 或检查 `package.json` 获取版本信息。新建项目时，除非用户明确指定，否则不应固定单一版本。

生成或修改 Angular 代码后，执行 `ng build` 以尽早检测错误。

## 文件命名

遵循 Angular CLI 约定 —— 每个文件一个定义：

- `user-profile.component.ts` + `user-profile.component.html` + `user-profile.component.spec.ts`
- `user.service.ts`、`auth.guard.ts`、`date-format.pipe.ts`
- 特性文件夹：`features/users/`、`features/auth/`
- 使用 CLI 生成：`ng generate component features/users/user-card`

## 组件

优先使用独立组件（standalone，v17+ 默认为独立组件）。所有新组件应使用 `OnPush` 变更检测。

```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [RouterModule],
  templateUrl: './user-card.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserCardComponent {
  user = input.required<User>();
  select = output<string>();
}
```

## 依赖注入

使用 `inject()` 替代构造函数注入。保持构造函数为空或直接移除。

```typescript
// 推荐
@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);
  private router = inject(Router);
}

// 不推荐：构造函数注入冗长且不利于 tree-shake
constructor(private http: HttpClient, private router: Router) {}
```

非类依赖使用 `InjectionToken`：

```typescript
const API_URL = new InjectionToken<string>('API_URL');

// 提供：
{ provide: API_URL, useValue: 'https://api.example.com' }

// 消费：
private apiUrl = inject(API_URL);
```

## Signals

### 核心原语

```typescript
count = signal(0);
doubled = computed(() => this.count() * 2);

increment() {
  this.count.update(n => n + 1);
}
```

### `linkedSignal` —— 可写派生状态

当 signal 需要在源变化后重置或适配，同时允许独立写入时，使用 `linkedSignal`：

```typescript
selectedOption = linkedSignal(() => this.options()[0]);
// options 变化时重置为首项，用户可独立修改
```

### `resource` —— 异步数据集成到 Signals

使用 `resource()` 响应式获取异步数据，无需手动订阅：

```typescript
userResource = resource({
  request: () => ({ id: this.userId() }),
  loader: ({ request }) => fetch(`/api/users/${request.id}`).then(r => r.json()),
});

// 访问：userResource.value()、userResource.isLoading()、userResource.error()
```

### `effect` 使用方式

`effect()` 仅用于响应 signal 变化的副作用（日志、第三方 DOM 操作）。不应使用 effect 同步 signals —— 应使用 `computed` 或 `linkedSignal`。渲染后 DOM 操作使用 `afterRenderEffect`。

```typescript
// 推荐：副作用
effect(() => console.log('User changed:', this.user()));

// 不推荐：此场景应使用 computed
effect(() => { this.fullName.set(`${this.first()} ${this.last()}`); });
```

## 模板

使用 v17+ 的块语法。`@for` 中必须包含 `track`：

```html
@for (item of items(); track item.id) {
  <app-item [item]="item" />
}

@if (isLoading()) {
  <app-spinner />
} @else if (error()) {
  <app-error [message]="error()" />
} @else {
  <app-content [data]="data()" />
}
```

除简单条件判断外，避免在模板中嵌入逻辑 —— 移至组件方法或管道。

## 表单

选择与项目现有方案一致的表单策略：

- **Signal Forms**（v21+）：v21+ 新项目推荐。基于 signal 的表单状态。
- **响应式表单**：`FormBuilder` + `FormGroup` + `FormControl`。适用于动态验证的复杂表单。
- **模板驱动表单**：`ngModel`。仅适用于简单表单。

```typescript
// 响应式表单 — 多数应用的标准方案
export class LoginComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  submit() {
    if (this.form.valid) {
      // 使用 this.form.value
    }
  }
}
```

## 组件样式

使用组件级样式，保持 `ViewEncapsulation.Emulated`（默认值）。除非在设计系统中刻意允许样式穿透，否则不应使用 `ViewEncapsulation.None`。

- 样式保持在组件范围内 —— 不在组件样式表中定义全局 class 名
- 使用 `:host` 为宿主元素添加样式
- 可主题化值优先使用 CSS 自定义属性

## 变更检测

- 所有新组件默认使用 `ChangeDetectionStrategy.OnPush`
- Signals 和 `async` 管道自动处理检测 —— 不应再使用 `markForCheck()` 和 `detectChanges()`
- 使用 OnPush 时不应就地修改 `@Input()` 对象
