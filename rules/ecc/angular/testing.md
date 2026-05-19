---
paths:
  - "**/*.spec.ts"
  - "**/*.test.ts"
---
# Angular 测试

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 Angular 特定的测试实践。

## 测试运行器

使用项目中配置的测试运行器。检查 `angular.json` 和 `package.json`；Angular 项目通常使用 Vitest、Jest 或 Jasmine + Karma。

```bash
ng test               # watch 模式
ng test --no-watch    # CI 模式
```

## TestBed 设置

独立组件直接导入。具有外部模板的组件需要调用 `compileComponents()`。

```typescript
describe('UserCardComponent', () => {
  let fixture: ComponentFixture<UserCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserCardComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(UserCardComponent);
  });
});
```

## Signal 输入

通过 `fixture.componentRef.setInput()` 设置基于 signal 的输入：

```typescript
fixture.componentRef.setInput('user', mockUser);
fixture.detectChanges();
```

## 组件 Harness

进行 UI 交互测试时，优先使用 Angular CDK 的组件 harness，而非直接查询 DOM。Harness 对标记变更的适应性更强。

```typescript
import { HarnessLoader } from '@angular/cdk/testing';
import { TestbedHarnessEnvironment } from '@angular/cdk/testing/testbed';
import { MatButtonHarness } from '@angular/material/button/testing';

let loader: HarnessLoader;

beforeEach(() => {
  loader = TestbedHarnessEnvironment.loader(fixture);
});

it('triggers save on button click', async () => {
  const button = await loader.getHarness(MatButtonHarness.with({ text: 'Save' }));
  await button.click();
  expect(saveSpy).toHaveBeenCalled();
});
```

## Router 测试

依赖于路由器的组件使用 `RouterTestingHarness`：

```typescript
import { RouterTestingHarness } from '@angular/router/testing';

it('renders user on navigation', async () => {
  const harness = await RouterTestingHarness.create();
  const component = await harness.navigateByUrl('/users/1', UserDetailComponent);
  expect(component.userId()).toBe('1');
});
```

## 异步测试

使用 `fakeAsync` + `tick` 进行可控的异步测试。使用 `waitForAsync` 配合 `fixture.whenStable()` 进行真实的异步测试。

```typescript
it('loads user after delay', fakeAsync(() => {
  const service = TestBed.inject(UserService);
  vi.spyOn(service, 'getUser').mockReturnValue(of(mockUser));

  fixture.detectChanges();
  tick();
  fixture.detectChanges();

  expect(fixture.nativeElement.querySelector('.name').textContent).toBe(mockUser.name);
}));
```

## HTTP 测试

```typescript
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { HttpTestingController } from '@angular/common/http/testing';

beforeEach(() => {
  TestBed.configureTestingModule({
    providers: [provideHttpClient(), provideHttpClientTesting()],
  });
  httpMock = TestBed.inject(HttpTestingController);
});

afterEach(() => httpMock.verify());
```

## 服务测试

无需组件 fixture，直接注入服务：

```typescript
describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(UserService);
  });
});
```

## 测试范围

- **服务**：所有 public 方法、错误路径、HTTP 交互
- **组件**：输入/输出绑定、关键状态的渲染输出、通过 harness 实现的用户交互
- **管道**：纯转换 —— 纯单元测试，无需 TestBed
- **守卫/解析器**：使用 `RouterTestingHarness` 测试允许和拒绝状态的返回值

## E2E 测试

使用项目配置的 E2E 框架（如 Cypress 或 Playwright）测试关键用户流程。

```typescript
describe('Login flow', () => {
  it('redirects to dashboard on valid credentials', () => {
    cy.visit('/login');
    cy.get('[data-cy=email]').type('user@example.com');
    cy.get('[data-cy=password]').type('password123');
    cy.get('[data-cy=submit]').click();
    cy.url().should('include', '/dashboard');
  });
});
```

- 为交互元素添加 `data-cy` 属性以获得稳定的选择器
- E2E 测试中不应使用 CSS class 或文本内容作为选择器

## 覆盖率

服务和管道的覆盖率目标 >= 80%。组件：测试行为，而非实现细节。

## 技能参考

参见技能：`angular-developer`，其中包含全面的测试模式、harness 用法和异步最佳实践。
