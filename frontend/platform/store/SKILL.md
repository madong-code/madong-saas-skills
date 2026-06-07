---
name: madong-frontend-platform-store
description: Platform 前端状态管理规范，auth(无多租户) + dict + site-config
globs:
  - "apps/platform/src/store/**/*.ts"
---

## 文件位置

```
apps/platform/src/store/
├── index.ts                     # Store 导出
├── auth.ts                      # 认证状态（无多租户切换逻辑）
└── modules/
    ├── dict.ts                  # 字典缓存
    └── site-config.ts           # 系统配置
```

## 认证 Store (auth.ts)

```typescript
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', () => {
  const loginLoading = ref(false);

  // 登录流程：获取 token → 用户信息 → 权限码
  async function authLogin(params, onSuccess?) {
    const { access_token, refresh_token } = await loginApi(params);
    accessStore.setAccessToken(access_token);
    accessStore.setRefreshToken(refresh_token);
    // 注意：Platform 不存储 tenant_id

    const [userInfo, accessCodes] = await Promise.all([
      fetchUserInfo(),
      getAccessCodesApi(),
    ]);
  }

  async function logout(redirect = true) { ... }
  async function fetchUserInfo() { ... }

  return { authLogin, logout, fetchUserInfo, loginLoading };
});
```

## 与 Admin Store 的差异

| Store | admin | platform |
|-------|-------|----------|
| `auth.ts` | 含多租户切换（fetchTenantList/switchTenant） | 无多租户逻辑 |
| `modules/notify.ts` | 有（WebSocket Push） | 无 |
| `modules/dict.ts` | 有 | 有（一致） |
| `modules/site-config.ts` | 有 | 有（一致） |

## 字典 Store (modules/dict.ts)

与 Admin 完全一致，字典缓存机制相同。

## 关键约定

- 使用 Pinia 的 setup 语法（`defineStore('{name}', () => { ... })`）
- Store 命名：`use{Name}Store`
- **无多租户**：authStore 不含 `fetchTenantList` / `switchTenant`
- **无消息通知**：没有 notify Store
- 字典 Store 做了缓存，同一字典只请求一次

## 检查清单

- [ ] Store 是否使用 setup 语法
- [ ] 是否不需要多租户切换逻辑
- [ ] 字典是否使用了缓存机制
