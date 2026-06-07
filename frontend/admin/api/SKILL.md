---
name: madong-frontend-admin-api
description: Admin 前端 API 层规范，requestClient + SSE + 多租户 X-Tenant-Id 注入
globs:
  - "apps/admin/src/api/**/*.ts"
---

## 文件位置

```
apps/admin/src/api/
├── request.ts                       # requestClient 实例 + SSE 封装
├── index.ts                         # 聚合导出
├── auth/                            # 认证 API
├── core/                            # 核心 API（refreshToken）
├── {module}/
│   ├── index.ts                     # API 函数
│   └── types.ts                     # 请求/响应类型定义
```

## request.ts - 请求客户端

```typescript
import { RequestClient } from '@vben/request';

// apiURL 由 useAppConfig 从环境变量获取，代理 /adminapi
export const requestClient = createRequestClient(apiURL, {
  responseReturn: 'data',
});
```

### 关键：多租户 X-Tenant-Id 注入

Admin 的 request.ts 在请求拦截器中注入租户 ID：

```typescript
client.addRequestInterceptor({
  fulfilled: async (config) => {
    config.headers.Authorization = formatToken(accessStore.accessToken);
    config.headers['Accept-Language'] = preferences.app.locale;

    // 多租户：注入租户ID（SaaS 管理接口跳过）
    if (
      accessStore.tenantId &&
      !config.url?.startsWith('/tenant') &&
      !config.url?.startsWith('/db-settings') &&
      !config.url?.startsWith('/db-drivers') &&
      !config.url?.startsWith('/subscription')
    ) {
      config.headers['X-Tenant-Id'] = String(accessStore.tenantId);
    }

    return config;
  },
});
```

### SSE 封装

request.ts 内置 `sse()` 函数，基于原生 EventSource 封装：

```typescript
import { sse } from '#/api/request';

const conn = sse('/content/message/notify/sse', {
  onOpen: () => console.log('连接成功'),
  success: (payload) => { console.log('unread:', payload?.data?.data); },
  error: (payload) => { console.error('服务端错误:', payload?.data?.message); },
  onError: (event) => console.error('连接错误'),
});

conn.close();
```

特性：
- 自动注入认证 Token（通过 URL 参数，EventSource 不支持自定义 headers）
- 同 URL 连接缓存，防止重复创建
- 支持自定义事件监听（success/error/progress/heartbeat 等）
- 支持 extraParams 注入额外参数

## API 函数模板

```typescript
// apps/admin/src/api/{module}/index.ts
import { requestClient } from '#/api/request';
import type { {Model}Query, {Model}Record, {Model}PageResult } from './types';

/** 获取列表 */
export function get{Model}List(params: {Model}Query) {
  return requestClient.get<{Model}PageResult>('/{module_route}', { params });
}

/** 创建 */
export function create{Model}(data: Recordable) {
  return requestClient.post('/{module_route}', data);
}

/** 更新 */
export function update{Model}(id: number, data: Recordable) {
  return requestClient.put(`/{module_route}/${id}`, data);
}

/** 删除 */
export function delete{Model}(id: number | number[]) {
  return requestClient.delete(`/{module_route}/${id}`);
}

/** 更新状态 */
export function change{Model}Status(data: { id: number; status: number }) {
  return requestClient.put('/{module_route}/changeStatus', data);
}
```

## 类型定义模板

```typescript
// apps/admin/src/api/{module}/types.ts
export interface {Model}Query {
  page?: number;
  limit?: number;
  name?: string;
  status?: number;
}

export interface {Model}Record {
  id: number;
  name: string;
  status: number;
  sort: number;
  created_at: number;
  updated_at: number;
}

export interface {Model}PageResult {
  items: {Model}Record[];
  total: number;
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system / member / content / ops / tenant / plugin / web / devtools |
| `{module_route}` | system/menu / member/user |
| `{Model}` | Menu / Member / Article |

## 关键约定

- API 文件统一放在 `apps/admin/src/api/{module}/` 目录
- 每个业务模块一个文件夹，包含 `index.ts` + `types.ts`
- 函数命名：`get{Model}List` / `create{Model}` / `update{Model}` / `delete{Model}`
- 类型接口命名：`{Model}Query`(查询) / `{Model}Record`(记录) / `{Model}PageResult`(分页)
- 代理目标为 `/adminapi`
- **多租户**：请求拦截器自动注入 `X-Tenant-Id` 头（SaaS 管理接口除外）

## 检查清单

- [ ] requestClient 实例是否已正确初始化
- [ ] 多租户 X-Tenant-Id 注入逻辑是否正确
- [ ] API 函数命名是否符合 `get{Model}List` / `create{Model}` 格式
- [ ] 类型定义是否包含 Query / Record / PageResult
- [ ] SSE 是否使用了 `sse()` 函数
