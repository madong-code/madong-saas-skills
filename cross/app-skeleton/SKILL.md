---
name: madong-cross-app-skeleton
description: 新增前端站点脚手架规范
globs:
  - "apps/admin/**"
  - "apps/platform/**"
  - "apps/install/**"
---

## 概述

新增一个前端站点（如 `apps/xxx/`）时，复制现有站点模板并修改以下配置。

## 新增站点步骤

### 1. 复制模板

推荐复制 `apps/admin/` 作为模板（功能最完整）：

```bash
cp -r apps/admin apps/{new_app}
```

### 2. 修改 package.json

```json
{
  "name": "@madong/{new_app}",
  "version": "5.7.0",
  "dependencies": {
    // 保持 catalog: 依赖不变
  }
}
```

### 3. 修改 Vite 配置

```typescript
// 在 vite.config.ts 中修改代理
proxy: {
  '/{new_app_route}': {
    target: 'http://127.0.0.1:8500/{new_app_route}',
    changeOrigin: true,
  },
}
```

### 4. 修改 preferences.ts

```typescript
export const overridesPreferences = defineOverridesPreferences({
  app: {
    name: import.meta.env.VITE_APP_TITLE,
    accessMode: 'backend',
  },
});
```

### 5. 修改路由前缀

- 后端新增对应的 `app/{new_app_route}/` 目录结构
- 注册路由在前缀 `/{new_app_route}/` 下
- 菜单数据在 `resource/data/menu/{new_app_route}.php`

### 6. 可选：插件路由适配

如需支持插件路由，添加 `router/plugin/` 目录的扫描逻辑。

## 关键区别

| 场景 | Vben 站点 | 独立站点 |
|------|-----------|---------|
| admin / platform | 使用 Vben 框架（`@vben/*`），完整的 CRUD/组件/SSE | - |
| install | 轻量独立应用（ElementPlus + axios），无 Vben 依赖 | - |
| 新站点 | 多数情况使用 Vben 模板 | 仅当类似 install 时才独立 |

## 检查清单

- [ ] 包名是否改为 `@madong/{new_app}`
- [ ] Vite 代理是否配置了正确的路由前缀
- [ ] 后端是否有对应的 `app/{new_app_route}/` 目录
- [ ] 菜单数据是否已添加到 `resource/data/menu/{new_app}.php`
- [ ] 是使用 Vben 模板还是独立站点模式
