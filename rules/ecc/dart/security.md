---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/AndroidManifest.xml"
  - "**/Info.plist"
---
# Dart/Flutter 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 Dart、Flutter 及移动端特定的安全实践。

## 密钥管理

- 不应在 Dart 源码中硬编码 API 密钥、令牌或凭据
- 使用 `--dart-define` 或 `--dart-define-from-file` 进行编译时配置（注意这些值并非真正保密 —— 服务端密钥应通过后端代理处理）
- 使用 `flutter_dotenv` 或类似方案，将 `.env` 文件加入 `.gitignore`
- 运行时密钥存储于平台安全存储中：`flutter_secure_storage`（iOS 使用 Keychain，Android 使用 EncryptedSharedPreferences）

```dart
// 不推荐
const apiKey = 'sk-abc123...';

// 推荐 —— 编译时配置（非机密，可配置）
const apiKey = String.fromEnvironment('API_KEY');

// 推荐 —— 从安全存储读取运行时密钥
final token = await secureStorage.read(key: 'auth_token');
```

## 网络安全

- 强制使用 HTTPS —— 生产环境不应出现 `http://` 调用
- 配置 Android 的 `network_security_config.xml` 阻止明文流量
- 在 `Info.plist` 中设置 `NSAppTransportSecurity` 禁止任意加载
- 为所有 HTTP 客户端设置请求超时 —— 不应使用默认值
- 高安全性端点可考虑证书固定

```dart
// Dio 配置超时和 HTTPS 强制
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
));
```

## 输入验证

- 发送到 API 或存储前，验证并清理所有用户输入
- 不应将未清理的输入传递给 SQL 查询 —— 使用参数化查询（sqflite、drift）
- 导航前清理深度链接 URL —— 验证 scheme、host 和路径参数
- 使用 `Uri.tryParse` 并在导航前验证

```dart
// 不推荐 —— SQL 注入
await db.rawQuery("SELECT * FROM users WHERE email = '$userInput'");

// 推荐 —— 参数化查询
await db.query('users', where: 'email = ?', whereArgs: [userInput]);

// 不推荐 —— 未验证的深度链接
final uri = Uri.parse(incomingLink);
context.go(uri.path); // 可能导航到任意路由

// 推荐 —— 验证后的深度链接
final uri = Uri.tryParse(incomingLink);
if (uri != null && uri.host == 'myapp.com' && _allowedPaths.contains(uri.path)) {
  context.go(uri.path);
}
```

## 数据保护

- 令牌、个人身份信息（PII）和凭据仅存储于 `flutter_secure_storage`
- 不应将敏感数据明文写入 `SharedPreferences` 或本地文件
- 退出登录时清理认证状态：令牌、缓存的用户数据、cookie
- 敏感操作使用生物识别认证（`local_auth`）
- 不应记录敏感数据 —— 禁止 `print(token)` 或 `debugPrint(password)`

## Android 特定

- 在 `AndroidManifest.xml` 中仅声明实际需要的权限
- 仅在必要时导出 Android 组件（`Activity`、`Service`、`BroadcastReceiver`）；不需要时添加 `android:exported="false"`
- 审查 intent filter —— 带隐式 intent filter 的导出组件可被任何应用访问
- 显示敏感数据的屏幕使用 `FLAG_SECURE`（防止截图）

```xml
<!-- AndroidManifest.xml —— 限制导出组件 -->
<activity android:name=".MainActivity" android:exported="true">
    <!-- 仅启动器 Activity 需要 exported=true -->
</activity>
<activity android:name=".SensitiveActivity" android:exported="false" />
```

## iOS 特定

- 在 `Info.plist` 中仅声明需要的使用说明（`NSCameraUsageDescription` 等）
- 密钥存储于 Keychain —— `flutter_secure_storage` 在 iOS 上使用 Keychain
- 使用 App Transport Security (ATS) —— 禁止任意加载
- 为敏感文件启用数据保护授权

## WebView 安全

- 使用 `webview_flutter` v4+（`WebViewController` / `WebViewWidget`）—— 旧版 `WebView` 组件已移除
- 除非明确需要，否则禁用 JavaScript（`JavaScriptMode.disabled`）
- 加载前验证 URL —— 不应从深度链接加载任意 URL
- 除非绝对必要且经过仔细沙箱化，不应将 Dart 回调暴露给 JavaScript
- 使用 `NavigationDelegate.onNavigationRequest` 拦截并验证导航请求

```dart
// webview_flutter v4+ API（WebViewController + WebViewWidget）
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.disabled) // 除非必要，否则禁用
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        if (uri == null || uri.host != 'trusted.example.com') {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  );

// 在 widget 树中使用：
WebViewWidget(controller: controller)
```

## 混淆与构建安全

- 发布构建时启用混淆：`flutter build apk --obfuscate --split-debug-info=./debug-info/`
- 将 `--split-debug-info` 的输出置于版本控制之外（仅用于崩溃符号化）
- 确保 ProGuard/R8 规则不会无意暴露序列化类
- 发布前执行 `flutter analyze` 并处理所有警告
