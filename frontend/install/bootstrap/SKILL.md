---
name: madong-frontend-install-bootstrap
description: Install 前端启动引导规范，直接 createApp + ElementPlus + Pinia（独立轻量应用）
globs:
  - "apps/install/src/main.ts"
  - "apps/install/package.json"
---

## 文件位置

```
apps/install/src/
├── main.ts                    # 应用入口（直接启动）
└── App.vue                    # 根组件（包含全部安装步骤逻辑）
```

## 启动流程

Install 不使用 Vben 框架，直接启动：

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

## 包配置

```json
// apps/install/package.json
{
  "name": "@madong/install",
  "version": "5.7.0",
  "type": "module",
  "imports": {
    "#/*": "./src/*"            // 注意：部分文件使用 @/ 别名
  },
  "dependencies": {
    "vue": "catalog:",
    "element-plus": "catalog:",
    "pinia": "catalog:",
    "axios": "catalog:",
    "vue-router": "catalog:"
    // 注意：不依赖 @vben/* 包
  }
}
```

## 与 Admin/Platform 的关键差异

| 维度 | admin/platform | install |
|------|---------------|---------|
| 框架 | Vben Admin 5 | 直接 ElementPlus |
| 启动 | initPreferences + bootstrap | createApp + ElementPlus |
| 依赖 | @vben/* 全家桶 | 仅 vue + element-plus + pinia + axios |
| 路由 | 后端菜单驱动 | 简单步骤路由 |
| 布局 | Vben Layout 系统 | 单页面无布局 |

## 关键约定

- Install 是独立轻量应用，不依赖 `@vben/*` 工作区包
- 包名：`@madong/install`
- 直接使用 ElementPlus 注册组件，无需 Vben 适配器
- App.vue 包含全部安装步骤逻辑（约 12KB）

## 检查清单

- [ ] 是否使用了正确的启动模式（非 Vben）
- [ ] 是否不依赖 @vben/* 包
- [ ] 包名是否为 `@madong/install`
