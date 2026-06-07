---
name: madong-frontend-platform-api
description: Platform 前端 API 层规范，requestClient + SSE（无多租户头注入）
globs:
  - "apps/platform/src/api/**/*.ts"
---

## 文件位置

```
apps/platform/src/api/
├── request.ts                       # requestClient 实例 + SSE 封装
├── index.ts                         # 聚合导出
├── core/                            # 核心 API（refreshToken）
├── {module}/
│   ├── index.ts                     # API 函数
│   └── types.ts                     # 请求/响应类型定义
```

## request.ts - 请求客户端

```typescript
import { RequestClient } from '@vben/request';

// apiURL 由 useAppConfig 从环境变量获取，代理 /platformapi
export const requestClient = createRequestClient(apiURL, {
  responseReturn: 'data',
});
```

### 与 Admin 的差异：无多租户 X-Tenant-Id 注入

Platform 的请求拦截器仅注入 Authorization 和 Accept-Language，**不注入** X-Tenant-Id：

```typescript
client.addRequestInterceptor({
  fulfilled: async (config) => {
    config.headers.Authorization = formatToken(accessStore.accessToken);
    config.headers['Accept-Language'] = preferences.app.locale;
    // 注意：Platform 不注入 X-Tenant-Id
    return config;
  },
});
```

### SSE 封装

与 Admin 完全一致，内置 `sse()` 函数：

```typescript
import { sse } from '#/api/request';

const conn = sse('/module/endpoint', {
  success: (payload) => { /* 处理成功事件 */ },
  error: (payload) => { /* 处理错误事件 */ },
});
conn.close();
```

## API 函数模板

```typescript
// apps/platform/src/api/{module}/index.ts
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
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system / tenant / plugin / database / monitor |
| `{module_route}` | system/menu / tenant/account |
| `{Model}` | Menu / Tenant / Plugin |

## 关键约定

- API 文件统一放在 `apps/platform/src/api/{module}/` 目录
- 函数命名：`get{Model}List` / `create{Model}` / `update{Model}` / `delete{Model}`
- 代理目标为 `/platformapi`
- **无多租户**：请求拦截器不注入 X-Tenant-Id 头

## 检查清单

- [ ] requestClient 实例是否已正确初始化
- [ ] 是否需要多租户头注入（Platform 不需要）
- [ ] API 函数命名是否符合格式
- [ ] 类型定义是否包含 Query / Record / PageResult
