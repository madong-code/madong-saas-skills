---
name: madong-frontend-admin-component
description: Admin 特有组件规范，tenant-switch/terminal 等
globs:
  - "apps/admin/src/components/tenant-switch/**/*"
  - "apps/admin/src/components/terminal/**/*"
  - "apps/admin/src/utils/sse/**/*"
---

## Admin 特有组件

Admin 除了共享的基础组件（crud/dialog/form/render/icon/page，见 `shared/component`），还有以下特有组件：

### tenant-switch/ - 租户切换

```typescript
// 用于多租户场景下切换当前租户
// 调用 authStore.switchTenant(tenantId) 切换租户
// 切换后重新加载用户信息、权限码、路由
```

### terminal/ - Web 终端

```typescript
// 在线终端组件，支持命令执行和 SSE 实时输出
// 命令模块：composer/npm/pnpm/build 等
// SSE 连接通过 api/request.ts 的 sse() 函数
```

### utils/sse/ - SSE 工具

```typescript
// Admin 独有的 SSE 工具函数
// 其他应用不使用此目录
```

## 关键约定

- Admin 特有组件放在 `components/` 目录下，与共享组件并列
- 租户切换逻辑依赖 `authStore.switchTenant()`，切换后需重置路由
- 终端组件使用 SSE 实时输出，通过 `sse()` 函数建立连接
- 组件命名使用大驼峰

## 检查清单

- [ ] 租户切换是否正确调用了 authStore.switchTenant
- [ ] SSE 连接是否使用 sse() 函数
- [ ] 组件命名是否使用大驼峰
