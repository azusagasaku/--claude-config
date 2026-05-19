---
paths:
  - "**/*.ets"
  - "**/*.ts"
---
# HarmonyOS / ArkTS 模式

> 本文件扩展了 [common/patterns.md](../common/patterns.md)，补充 HarmonyOS / ArkTS 特定的设计模式。

## 状态管理：仅限 V2

**必须使用** ArkUI 状态管理 V2。V1 装饰器已废弃，不应再使用。

### V2 装饰器

| 装饰器 | 用途 |
|-----------|---------|
| `@ComponentV2` | 将 struct 标记为 V2 组件 |
| `@Local` | 组件内的局部状态 |
| `@Param` | 从父组件接收的属性（只读） |
| `@Event` | 从子到父的回调事件 |
| `@Provider` | 向后代组件提供状态 |
| `@Consumer` | 从祖先 `@Provider` 消费状态 |
| `@Monitor` | 监听状态变化（替代 V1 的 `@Watch`） |
| `@Computed` | 派生/计算值 |
| `@ObservedV2` | 使类可被 V2 状态管理观察 |
| `@Trace` | 在 `@ObservedV2` 类中标记可观察的属性 |

### 禁用的 V1 装饰器

以下 V1 装饰器均被禁用：`@State`、`@Prop`、`@Link`、`@ObjectLink`、`@Observed`、`@Provide`、`@Consume`、`@Watch`、`@Component`（应使用 `@ComponentV2` 替代）。

### V2 组件示例

```typescript
@ObservedV2
class UserModel {
  @Trace name: string = ''
  @Trace age: number = 0
}

@ComponentV2
struct UserCard {
  @Param user: UserModel = new UserModel()
  @Event onDelete: () => void = () => {}

  build() {
    Column() {
      Text(this.user.name)
        .fontSize($r('app.float.font_size_title'))
      Text(`${this.user.age}`)
        .fontSize($r('app.float.font_size_body'))
      Button($r('app.string.delete'))
        .onClick(() => this.onDelete())
    }
  }
}
```

### 状态同步

```typescript
@ComponentV2
struct ParentPage {
  @Provider('userState') userModel: UserModel = new UserModel()

  build() {
    Column() {
      ChildComponent()  // 自动接收 @Consumer('userState')
    }
  }
}

@ComponentV2
struct ChildComponent {
  @Consumer('userState') userModel: UserModel = new UserModel()

  build() {
    Text(this.userModel.name)
  }
}
```

## 路由：仅限 Navigation

**必须使用** `Navigation` 组件配合 `NavPathStack`。不应再使用 `@ohos.router`。

### Navigation 设置

```typescript
@ComponentV2
struct MainPage {
  @Local navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack) {
      // 首页内容
    }
    .navDestination(this.routerMap)
  }

  @Builder
  routerMap(name: string, param: ESObject) {
    if (name === 'detail') {
      DetailPage()
    } else if (name === 'settings') {
      SettingsPage()
    }
  }
}
```

### 页面导航

```typescript
// 推送新页面
this.navPathStack.pushPath({ name: 'detail', param: { id: '123' } })

// 替换当前页面
this.navPathStack.replacePath({ name: 'settings' })

// 返回
this.navPathStack.pop()

// 返回根页面
this.navPathStack.clear()
```

### NavDestination 子页面

```typescript
@ComponentV2
struct DetailPage {
  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.detail_title'))
      }
    }
    .title($r('app.string.detail_nav_title'))
  }
}
```

## 架构模式：MVVM

推荐的 HarmonyOS 应用架构：

```
feature/
  |-- model/           # 数据模型（@ObservedV2 类）
  |-- viewmodel/       # 业务逻辑（ViewModel 类）
  |-- view/            # UI 组件（@ComponentV2 struct）
  |-- service/         # API 调用、数据访问
```

- **View**：仅负责渲染逻辑，`build()` 中不应包含业务逻辑。
- **ViewModel**：承载所有业务逻辑。
- **Model**：纯数据类，配合 `@ObservedV2` 和 `@Trace` 使用。
- **Service**：网络请求、数据库操作、文件 I/O。

## ArkUI 动画模式

### 状态驱动动画

```typescript
@ComponentV2
struct AnimatedCard {
  @Local isExpanded: boolean = false
  @Local cardScale: number = 0.8

  build() {
    Column() {
      // 内容
    }
    .scale({ x: this.cardScale, y: this.cardScale })
    .animation({ duration: 300, curve: Curve.EaseInOut })
    .onClick(() => {
      this.isExpanded = !this.isExpanded
      this.cardScale = this.isExpanded ? 1.0 : 0.8
    })
  }
}
```

### 动画规则

- 优先使用 HarmonyOS 原生动画 API 和高级模板。
- 使用声明式 UI 配合状态驱动动画（修改状态变量触发动画）。
- 复杂子组件动画设置 `renderGroup(true)` 以减少渲染批次。
- 避免在动画期间频繁修改 `width`、`height`、`padding`、`margin` —— 将导致性能严重下降。
- 使用 `animateTo` 进行显式动画控制。
- 高性能动画优先使用 `transform`（translate、scale、rotate）和 `opacity`。

## 性能模式

### 大列表使用 LazyForEach

```typescript
@ComponentV2
struct LargeList {
  @Local dataSource: MyDataSource = new MyDataSource()

  build() {
    List() {
      LazyForEach(this.dataSource, (item: ItemModel) => {
        ListItem() {
          ItemComponent({ item: item })
        }
      }, (item: ItemModel) => item.id)
    }
  }
}
```

### 组件复用

- 将可复用组件提取至独立文件中。
- 组件内轻量 UI 片段使用 `@Builder`。
- 可配置组件使用 `@Param`。

## 资源引用

UI 常量必须定义为资源，通过 `$r()` 引用：

```typescript
// 错误：硬编码值
Text('Hello')
  .fontSize(16)
  .fontColor('#333333')

// 正确：资源引用
Text($r('app.string.greeting'))
  .fontSize($r('app.float.font_size_body'))
  .fontColor($r('app.color.text_primary'))
```
