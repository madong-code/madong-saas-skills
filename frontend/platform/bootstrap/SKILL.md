---
name: madong-frontend-platform-bootstrap
description: Platform 前端启动引导规范，Vben 模式 + @madong/platform 包配置
globs:
  - "apps/platform/src/main.ts"
  - "apps/platform/src/bootstrap.ts"
  - "apps/platform/src/preferences.ts"
  - "apps/platform/src/layouts/**/*.vue"
  - "apps/platform/package.json"
---

## 文件位置

```
apps/platform/src/
├── main.ts                    # 应用入口（initPreferences + bootstrap）
├── bootstrap.ts               # 启动引导（组件适配器 + 国际化 + Pinia + Router）
├── preferences.ts             # 偏好配置
├── layouts/
│   ├── index.ts               # 布局导出
│   ├── auth.vue               # 认证页面布局
│   └── basic.vue              # 主应用布局
└── app.vue                    # 根组件
```

## 启动流程

与 Admin 完全一致：

```mermaid
main.ts → initPreferences → bootstrap → initComponentAdapter
                                         → initVbenForm
                                         → setupI18n
                                         → initStores
                                         → router
                                         → mount
```

### preferences.ts

```typescript
import { defineOverridesPreferences } from '@vben/preferences';

export const overridesPreferences = defineOverridesPreferences({
  app: {
    name: import.meta.env.VITE_APP_TITLE,
    accessMode: 'backend',
    enableRefreshToken: true,
  },
});
```

## 包配置

```json
// apps/platform/package.json
{
  "name": "@madong/platform",
  "version": "5.7.0",
  "type": "module",
  "imports": {
    "#/*": "./src/*"
  },
  "dependencies": {
    "@vben/access": "catalog:",
    "@vben/common-ui": "catalog:",
    "@vben/request": "catalog:",
    "@vben/stores": "catalog:",
    "vue": "catalog:",
    "element-plus": "catalog:"
  }
}
```

## 关键约定

- Platform 使用与 Admin 相同的 Vben 启动模式
- `preferences.ts` 中 `accessMode` 必须为 `'backend'`
- 包名：`@madong/platform`
- 启动引导顺序与 Admin 一致

## 检查清单

- [ ] main.ts 是否正确调用了 `initPreferences` 和 `bootstrap`
- [ ] preferences.ts 是否配置了 `accessMode: 'backend'`
- [ ] 包名是否为 `@madong/platform`
