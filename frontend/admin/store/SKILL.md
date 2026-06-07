---
name: madong-frontend-admin-store
description: Admin 前端状态管理规范，auth(多租户) + notify(WebSocket) + dict + site-config
globs:
  - "apps/admin/src/store/**/*.ts"
---

## 文件位置

```
apps/admin/src/store/
├── index.ts                     # Store 导出
├── auth.ts                      # 认证状态（含多租户切换逻辑）
└── modules/
    ├── dict.ts                  # 字典缓存
    ├── notify.ts                # 消息通知（WebSocket Push）
    └── site-config.ts           # 系统配置
```

## 认证 Store (auth.ts)

```typescript
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', () => {
  const loginLoading = ref(false);
  const tenantList = ref<AuthApi.TenantOption[]>([]);
  const tenantListLoading = ref(false);

  // 登录流程：获取 token → 存储 tenant_id → 用户信息 → 权限码
  async function authLogin(params, onSuccess?) {
    const loginResult = await loginApi(params);
    accessStore.setAccessToken(loginResult.access_token);
    accessStore.setRefreshToken(loginResult.refresh_token);
    // 存储租户ID（多租户模式）
    if (params.tenant_id) {
      accessStore.setTenantId(params.tenant_id);
    }
    // 获取用户信息 + 权限码
    const [userInfo, accessCodes] = await Promise.all([
      fetchUserInfo(),
      getAccessCodesApi(),
    ]);
  }

  // 获取租户列表（已登录状态下的租户切换）
  async function fetchTenantList() { ... }

  // 切换租户：更新 token → 重载用户信息 → 重置路由
  async function switchTenant(tenantId) { ... }

  return { authLogin, logout, fetchTenantList, switchTenant, tenantList, ... };
});
```

## 消息通知 Store (modules/notify.ts)

```typescript
// Admin 特有：WebSocket Push 消息通知
export const useNotifyStore = defineStore('notify', () => {
  const unreadCount = ref<UnreadCountData>({ total: 0, categories: [] });
  const messageList = ref<any[]>([]);
  const pushConnected = ref(false);

  // 初始化 Push 连接
  function initPush() {
    // 使用 Push SDK 连接 WebSocket
    // 订阅通道：backend-admin-{tenantId}-{userId}
    pushClient = new Push({ url: wssUrl, app_key: appKey, auth: '/adminapi/plugin/webman/push/auth' });
    const channel = pushClient.subscribe(`backend-admin-${tenantId}-${userId}`);
  }

  // 消息操作
  async function markRead(id) { ... }
  async function batchMarkRead(ids) { ... }
  async function markAllRead() { ... }

  return { unreadCount, messageList, initPush, markRead, ... };
});
```

## 字典 Store (modules/dict.ts)

```typescript
export const useDictStore = defineStore('dict', () => {
  const dictMap = ref<Record<string, DictItem[]>>({});

  // 字典缓存：同一字典只请求一次
  async function getDict(type: string): Promise<DictItem[]> {
    if (dictMap.value[type]) return dictMap.value[type];
    const data = await getDictData(type);
    dictMap.value[type] = data;
    return data;
  }

  return { dictMap, getDict };
});
```

## 关键约定

- 使用 Pinia 的 setup 语法（`defineStore('{name}', () => { ... })`）
- Store 命名：`use{Name}Store`，内部名称：`'{name}'`
- 状态用 `ref()` / `reactive()`，计算属性用 `computed()`，动作用普通函数
- **多租户切换**：authStore 含 `fetchTenantList` + `switchTenant`，切换后重置路由
- **消息通知**：notifyStore 使用 WebSocket Push，订阅 `backend-admin-{tenantId}-{userId}`
- 字典 Store 做了缓存，同一字典只请求一次

## 检查清单

- [ ] Store 是否使用 setup 语法（composition API）
- [ ] 多租户切换逻辑是否正确（switchTenant → 重置路由）
- [ ] notify Store 的 Push 连接是否正确初始化
- [ ] 字典是否使用了缓存机制
- [ ] 异步操作是否正确处理了 loading 状态
