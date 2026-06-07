---
name: madong-frontend-install-api
description: Install 前端 API 层规范，axios 请求客户端（独立轻量应用）
globs:
  - "apps/install/src/api/**/*.ts"
  - "apps/install/src/utils/request.ts"
---

## 文件位置

```
apps/install/src/
├── api/
│   └── install.ts             # Install API 函数
└── utils/
    └── request.ts             # axios 请求客户端（单例）
```

## request.ts - 请求客户端

Install 不使用 Vben 的 requestClient，而是自己封装 axios：

```typescript
import axios from 'axios';

class RequestClient {
  private instance: AxiosInstance;

  constructor() {
    this.instance = axios.create({
      baseURL: import.meta.env.VITE_GLOB_API_URL || '/adminapi',
      timeout: 30000,
      headers: { 'Content-Type': 'application/json' },
    });

    // 响应拦截器：直接返回 response.data
    this.instance.interceptors.response.use(
      (response) => response.data,
      (error) => Promise.reject(error),
    );
  }

  get<T>(url: string, config?) { return this.instance.get(url, config); }
  post<T>(url: string, data?, config?) { return this.instance.post(url, data, config); }
  put<T>(url: string, data?, config?) { return this.instance.put(url, data, config); }
  delete<T>(url: string, config?) { return this.instance.delete(url, config); }
}

const request = new RequestClient();
export default request;
export const { get, post, put, del } = request;
```

## install.ts - API 函数

```typescript
import request from '@/utils/request';

export const installApi = {
  checkInstall: () => request.get('/install/check'),
  getAgreement: () => request.get('/install/agreement'),
  environment: () => request.get('/install/environment'),
};
```

## SSE - 直接使用 EventSource

Install 不使用 `sse()` 函数，而是在 Store 中直接使用原生 EventSource：

```typescript
// 在 useInstallStore.simulateInstallation() 中
const eventSource = new EventSource(sseUrl);
eventSource.addEventListener('progress', (event) => { ... });
eventSource.addEventListener('completed', (event) => { ... });
eventSource.addEventListener('runtime_error', (event) => { ... });
```

## 关键约定

- Install 使用自定义 axios 封装，不依赖 `@vben/request`
- baseURL 默认 `/adminapi`（安装阶段后端只有 /adminapi/install 路由）
- 响应拦截器直接返回 `response.data`，不需要 Vben 的多层拦截
- SSE 直接使用原生 EventSource，不通过 request.ts 封装

## 检查清单

- [ ] 是否使用自定义 axios 而非 @vben/request
- [ ] baseURL 是否正确
- [ ] SSE 是否使用原生 EventSource
