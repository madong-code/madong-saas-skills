---
name: madong-frontend-platform-router
description: Platform 前端路由规范，后端菜单驱动 + 插件路由扫描
globs:
  - "apps/platform/src/router/**/*.ts"
---

## 文件位置

```
apps/platform/src/router/
├── index.ts                     # Router 实例创建
├── access.ts                    # 权限路由生成（后端菜单模式）
├── guard.ts                     # 路由守卫
├── routes/
│   ├── index.ts                 # 路由聚合
│   ├── core.ts                  # 核心路由（Root/Auth/404）
│   ├── backend.ts               # 后端模式路由（Profile）
│   └── modules/
│       └── {module}.ts          # 业务模块路由
└── plugin/
    ├── index.ts                 # 插件路由管理器
    └── scanner.ts               # 插件路由扫描器
```

## 路由 code 命名规范

```
Platform{Module}{Action}
```

示例：

| 路由 | code | 说明 |
|------|------|------|
| 系统菜单列表 | `PlatformSystemMenuList` | 系统菜单 |
| 租户列表 | `PlatformTenantList` | 租户管理 |
| 数据库管理 | `PlatformDatabaseList` | 数据库 |
| 监控管理 | `PlatformMonitorList` | 监控 |
| 插件管理 | `PlatformPluginList` | 插件列表 |

## 菜单数据文件

```
backend/resource/data/menu/platform.php
```

## 关键约定

- 路由模式为 `backend`（`preferences.ts` 中配置）
- 路由由后端菜单数据驱动，前端只需定义 `modules/{module}.ts` 的路由映射
- 路由 name 命名：`Platform{Module}{List}`
- 插件路由由 `plugin/` 下的管理器动态扫描注册
- 结构与 Admin 路由完全一致，仅 code 前缀不同（Platform vs Admin）

## 检查清单

- [ ] 路由 name 是否按 `Platform{Module}Action` 格式命名
- [ ] 新模块的路由是否在 `routes/modules/` 中创建了对应文件
- [ ] 菜单数据是否已在后端 `resource/data/menu/platform.php` 中配置
