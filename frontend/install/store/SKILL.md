---
name: madong-frontend-install-store
description: Install 前端状态管理规范，useInstallStore（选项式 API + SSE 安装进度）
globs:
  - "apps/install/src/store/**/*.ts"
---

## 文件位置

```
apps/install/src/store/
├── index.ts                     # Store 导出
└── module/
    └── install.ts               # 安装状态（选项式 API）
```

## useInstallStore (module/install.ts)

```typescript
import { defineStore } from 'pinia';

export const useInstallStore = defineStore('install', {
  state: () => ({
    agreementData: null,
    environmentData: { check_items: [], directory_check_items: [], passed: false, loading: false },
    databaseConfig: { host: 'localhost', port: 3306, username: 'root', password: 'root', database: 'madong', prefix: 'md_' },
    tenantConfig: { tenant_mode: 'none', enable_tenant: false, create_default_tenant: false, ... },
    adminConfig: { username: 'admin', password: '123456', email: '...', site_name: '...', ... },
    install_progress: 0,
    install_logs: [] as string[],
    install_status: 'idle' as 'error' | 'idle' | 'installing' | 'success',
    install_start_time: null as Date | null,
    installation_completed: false,
    saas_mode: false,
  }),

  getters: {
    installDuration: (state) => { /* 计算安装耗时 */ },
    formattedDuration: (state) => { /* 格式化耗时显示 */ },
    environmentPassed: (state) => { /* 检查环境是否通过 */ },
  },

  actions: {
    async fetchInstallationStatus() { /* 检查是否已安装 */ },
    async fetchAgreementData() { /* 获取协议 */ },
    async checkEnvironment() { /* 环境检测 */ },
    async simulateInstallation() {
      // 1. 构建 SSE URL（包含所有配置参数）
      // 2. 创建 EventSource 连接
      // 3. 监听 progress/runtime_error/completed 事件
      // 4. 实时更新 install_progress 和 install_logs
    },
    updateProgress(progress, log) { ... },
    installComplete() { ... },
    installFailed(error) { ... },
  },
});
```

## 与 Admin/Platform Store 的差异

| 维度 | admin/platform | install |
|------|---------------|---------|
| API 风格 | setup 语法（`() => {}`） | **选项式 API**（state/getters/actions） |
| 认证 | authStore (登录/登出) | 无认证（安装阶段） |
| SSE | request.ts 的 `sse()` 函数 | **原生 EventSource** |
| 数据 | 业务数据 | 安装配置 + 进度 |

## 关键约定

- 使用 Pinia 的**选项式 API**（与 admin/platform 的 setup 语法不同）
- 安装进度通过 SSE 实时更新
- SSE 连接在 `simulateInstallation()` 中直接创建，不使用 `sse()` 函数
- 安装配置（数据库/管理员/租户）全部存在 state 中
- 安装完成后设置 `installation_completed = true`

## 检查清单

- [ ] Store 是否使用选项式 API（非 setup 语法）
- [ ] SSE 是否使用原生 EventSource
- [ ] 安装进度是否正确更新
- [ ] 安装完成/失败状态是否正确设置
