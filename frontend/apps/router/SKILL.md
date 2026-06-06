---
name: madong-frontend-apps-router
description: 前端路由规范，路由code/守卫/菜单数据文件
globs:
  - "apps/**/src/router/**/*.ts"
---

## 文件位置

```
apps/{app}/src/router/
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
{App}{Module}{Action}
```

示例：

| 路由 | code | 说明 |
|------|------|------|
| 系统菜单列表 | `AdminSystemMenuList` | admin 端系统菜单 |
| 会员用户列表 | `AdminMemberUserList` | admin 端会员用户 |
| 租户列表 | `PlatformTenantList` | platform 端租户 |
| 系统设置 | `PlatformSettingList` | platform 端设置 |

## 路由守卫

`guard.ts` 中配置：

- 通用守卫：Token 检查、页面标题
- 权限守卫：从后端获取权限码后动态生成路由
- 路由模式为 `backend`（后端菜单模式），路由由后端菜单数据驱动

## 菜单数据文件

```
backend/resource/data/menu/
├── admin.php                    # Admin 端菜单数据
└── platform.php                 # Platform 端菜单数据
```

菜单数据中的 `routes` 字段对应前端路由 code。

## 关键约定

- 路由模式为 `backend`（`preferences.ts` 中配置）
- 路由由后端菜单数据驱动，前端只需定义 `modules/{module}.ts` 的路由映射
- 路由 name 命名：`{App}{Module}{List}`（与 `views/{module}/{name}/index.vue` 对应）
- `core.ts` 中的路由（Root/Auth/404）不需要菜单数据
- `backend.ts` 中的路由（Profile）用于个人信息页面
- 插件路由由 `plugin/` 下的管理器动态扫描注册

## 检查清单

- [ ] 路由 name 是否按 `{App}{Module}Action` 格式命名
- [ ] 新模块的路由是否在 `routes/modules/` 中创建了对应文件
- [ ] 菜单数据是否已在后端 `resource/data/menu/{app}.php` 中配置
