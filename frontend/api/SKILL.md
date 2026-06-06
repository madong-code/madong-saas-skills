---
name: madong-frontend-api
description: 前端 API 层规范，requestClient/SSE/BaseService 模式
globs:
  - "apps/**/src/api/**/*.ts"
---

## 文件位置

```
apps/{app}/src/api/
├── request.ts                       # requestClient 实例
├── index.ts                         # 聚合导出
├── {module}/
│   ├── index.ts                     # API 函数
│   └── types.ts                     # 请求/响应类型定义
```

## API 文件结构

### request.ts - 请求客户端（Vben 应用）

```typescript
import { requestClient } from '@vben/request';

// requestClient 已封装了 baseURL、token 注入、错误处理、刷新 token 等
// admin: 代理 /adminapi → http://127.0.0.1:8500/adminapi
// platform: 代理 /platformapi → http://127.0.0.1:8500/platformapi
```

### request.ts - 请求客户端（install 应用）

```typescript
import axios from 'axios';

const service = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/',
  timeout: 30000,
});

service.interceptors.response.use(
  (response) => response.data,
  (error) => Promise.reject(error),
);
```

### API 函数模板

```typescript
// apps/{app}/src/api/{module}/index.ts
import { requestClient } from '#/api/request';
import type { {Model}Query, {Model}Record, {Model}PageResult } from './types';

/** 获取列表 */
export function get{Model}List(params: {Model}Query) {
  return requestClient.get<{Model}PageResult>('/{module_route}', { params });
}

/** 获取详情 */
export function get{Model}Detail(id: number) {
  return requestClient.get<{Model}Record>(`/{module_route}/${id}`);
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

### 类型定义模板

```typescript
// apps/{app}/src/api/{module}/types.ts
/** 查询参数 */
export interface {Model}Query {
  page?: number;
  limit?: number;
  name?: string;
  status?: number;
}

/** 记录 */
export interface {Model}Record {
  id: number;
  name: string;
  status: number;
  sort: number;
  created_at: number;
  updated_at: number;
}

/** 分页结果 */
export interface {Model}PageResult {
  items: {Model}Record[];
  total: number;
}
```

## SSE API

```typescript
import { sse } from '#/utils/sse';

// 建立 SSE 连接
const eventSource = sse('/{module}/sse', {
  onMessage: (data) => { /* 处理消息 */ },
  onError: (error) => { /* 处理错误 */ },
});

// 手动关闭
eventSource.close();
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{app}` | admin / platform / install |
| `{module}` | system / member / content / ops |
| `{module_route}` | system/menu / member/user |
| `{Model}` | Menu / Member / Article |

## 关键约定

- API 文件统一放在 `apps/{app}/src/api/{module}/` 目录
- 每个业务模块一个文件夹，包含 `index.ts` + `types.ts`
- 函数命名：`get{Model}List` / `create{Model}` / `update{Model}` / `delete{Model}`
- 类型接口命名：`{Model}Query`(查询) / `{Model}Record`(记录) / `{Model}PageResult`(分页)
- 接口方法使用 `requestClient.get/post/put/delete`（Vben应用）或 `service.get/post`（install 应用）
- API 路径使用 snake_case、kebab-case
- **同一个 API 函数同时适用于 admin 和 platform**，只需切换 proxy 目标

## 检查清单

- [ ] requestClient 或 axios 实例是否已正确初始化
- [ ] API 函数命名是否符合 `get{Model}List` / `create{Model}` 格式
- [ ] 类型定义是否包含 Query / Record / PageResult
- [ ] install 应用是否使用了 axios 而非 requestClient
- [ ] SSE 是否使用了统一的 `sse()` 函数
