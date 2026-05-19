---
paths:
  - "**/*.ets"
  - "**/*.ts"
  - "**/module.json5"
---
# HarmonyOS / ArkTS 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 HarmonyOS / ArkTS 特定的安全实践。

## 权限管理

### 在 module.json5 中声明权限

所有需要权限的系统 API 调用必须先声明：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:internet_permission_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      }
    ]
  }
}
```

### 权限检查清单

调用系统 API 前，确认：

- [ ] 权限已在 `module.json5` 中声明
- [ ] 权限原因字符串已在资源中定义（针对面向用户的权限）
- [ ] 敏感权限（相机、位置等）已实现运行时权限请求
- [ ] API 调用前进行权限检查，被拒绝时优雅降级

### 运行时权限请求

```typescript
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';

async function checkAndRequestPermission(permission: Permissions): Promise<boolean> {
  const atManager = abilityAccessCtrl.createAtManager();
  const bundleInfo = await bundleManager.getBundleInfoForSelf(
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
  );
  const tokenId = bundleInfo.appInfo.accessTokenId;
  const grantStatus = await atManager.checkAccessToken(tokenId, permission);

  if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
    return true;
  }

  const result = await atManager.requestPermissionsFromUser(getContext(), [permission]);
  return result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
}
```

## 密钥管理

- **不应**在 `.ets`/`.ts` 源文件中硬编码 API key、token 或密码。
- 非敏感配置使用 HarmonyOS Preferences API。
- 敏感凭证使用 HarmonyOS Keystore。
- 环境特定配置应通过构建 profile 管理。

```typescript
// 不推荐：硬编码密钥
const API_KEY: string = 'sk-xxxxxxxxxxxx';

// 推荐：来自构建 profile 配置（非敏感）
import { BuildProfile } from 'BuildProfile';
const endpoint = BuildProfile.API_ENDPOINT;

// 推荐：使用 HUKS 加解密数据，不暴露密钥材料
import { huks } from '@kit.UniversalKeystoreKit';
async function decryptWithKeystore(alias: string, nonce: Uint8Array, aad: Uint8Array, cipherData: Uint8Array): Promise<Uint8Array> {
  const options: huks.HuksOptions = {
    properties: [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_GCM },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
      { tag: huks.HuksTag.HUKS_TAG_NONCE, value: nonce },
      { tag: huks.HuksTag.HUKS_TAG_ASSOCIATED_DATA, value: aad }
    ],
    inData: cipherData
  };
  const handle = await huks.initSession(alias, options);
  const result = await huks.finishSession(handle.handle, options);
  return result.outData;
}
```

## 输入验证

- 处理前验证所有用户输入。
- UI 展示前清理数据以防止注入。
- 导航前验证深度链接参数。

```typescript
// 导航前验证
function handleDeepLink(uri: string): void {
  const allowedPaths: string[] = ['detail', 'settings', 'profile'];
  const parsed = new URL(uri);
  const path = parsed.pathname.replace('/', '');

  if (!allowedPaths.includes(path)) {
    hilog.warn(0x0000, 'DeepLink', 'Invalid deep link path: %{public}s', path);
    return;
  }

  navPathStack.pushPath({ name: path });
}
```

## 网络安全

- 网络请求始终使用 HTTPS。
- 验证服务器证书。
- 实现请求超时和重试策略。
- 不应在网络请求/响应日志中记录敏感数据（token、用户凭据等）。

## 数据存储安全

- 敏感本地数据使用加密偏好设置。
- 不再需要时从内存中清除敏感数据。
- 实现正确的数据生命周期管理。
- 选择存储机制时应考虑数据分级（公开、内部、机密）。

## 依赖安全

- 仅使用来自可信来源的依赖（官方 ohpm 仓库）。
- 在 `oh-package.json5` 中验证依赖版本。
- 定期检查第三方库的已知漏洞。
- 固定依赖版本，避免意外更新引入问题。
