---
name: madong-frontend-bootstrap
description: 前端启动引导规范，main.ts/bootstrap/layouts/preferences
globs:
  - "apps/**/src/main.ts"
  - "apps/**/src/bootstrap.ts"
  - "apps/**/src/preferences.ts"
  - "apps/**/src/layouts/**/*.vue"
---

## 文件位置

```
apps/{app}/src/
├── main.ts                    # 应用入口（Vben 模式：initPreferences + bootstrap）
├── bootstrap.ts               # 启动引导（组件适配器 + 国际化 + Pinia + Router）
├── preferences.ts             # 偏好配置
├── layouts/
│   ├── index.ts               # 布局导出
│   ├── auth.vue               # 认证页面布局
│   └── basic.vue              # 主应用布局
└── app.vue                    # 根组件
```

## 启动流程（Vben 应用 - admin/platform）

```mermaid
main.ts → initPreferences → bootstrap → initComponentAdapter
                                         → initVbenForm
                                         → setupI18n
                                         → initStores
                                         → router
                                         → mount
```

### main.ts

```typescript
import { initPreferences } from '@vben/preferences';
import { unmountGlobalLoading } from '@vben/utils';
import { overridesPreferences } from './preferences';

async function initApplication() {
  const namespace = `${import.meta.env.VITE_APP_NAMESPACE}-${import.meta.env.VITE_APP_VERSION}`;
  await initPreferences({ namespace, overrides: overridesPreferences });
  const { bootstrap } = await import('./bootstrap');
  await bootstrap(namespace);
  unmountGlobalLoading();
}
initApplication();
```

### bootstrap.ts

```typescript
async function bootstrap(namespace: string) {
  // 1. 注册组件适配器
  await initComponentAdapter();
  // 2. 初始化表单
  await initSetupVbenForm();
  // 3. 创建 Vue 实例
  const app = createApp(App);
  // 4. 注册指令
  app.directive('loading', ElLoading.directive);
  // 5. 初始化国际化
  await setupI18n(app);
  // 6. 初始化状态管理
  app.use(createPinia());
  // 7. 初始化路由
  app.use(router);
  // 8. 挂载
  app.mount('#app');
}
```

### preferences.ts

```typescript
import { defineOverridesPreferences } from '@vben/preferences';

export const overridesPreferences = defineOverridesPreferences({
  app: {
    name: import.meta.env.VITE_APP_TITLE,
    accessMode: 'backend',         // 后端菜单模式
    enableRefreshToken: true,      // 开启刷新令牌
  },
});
```

## 启动流程（install 应用）

```typescript
// main.ts - 直接启动，不依赖 Vben 框架
async function bootstrap() {
  await initConfig();               // 初始化安装配置
  setDocumentTitle();               // 设置页面标题
  const app = createApp(App);
  app.use(ElementPlus);             // 直接使用 ElementPlus
  app.use(createPinia());
  app.mount('#app');
}
bootstrap();
```

## 关键约定

- **Vben 应用**（admin/platform）使用 `initPreferences + bootstrap` 模式
- **install 应用**使用简洁模式，直接 `createApp + ElementPlus + Pinia`
- `preferences.ts` 中的 `accessMode` 必须为 `'backend'`
- `namespace` 用于隔离本地存储（不同应用/版本互不干扰）
- 启动引导顺序不能改变：组件适配器 → 表单 → 国际化 → Pinia → 路由 → 挂载

## 检查清单

- [ ] main.ts 是否正确调用了 `initPreferences` 和 `bootstrap`
- [ ] preferences.ts 是否配置了 `accessMode: 'backend'`
- [ ] bootstrap 的执行顺序是否正确
- [ ] install 应用是否使用了正确的启动模式
