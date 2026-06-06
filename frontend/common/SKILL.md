---
name: madong-frontend-common
description: 前端公共规范，Monorepo 包结构/tsconfig/vite/package.json 约定
globs:
  - "apps/**/*"
---

## 项目架构

```
frontend/                              # Monorepo 根目录
├── pnpm-workspace.yaml                # 工作空间配置
├── turbo.json                         # Turbo 构建配置
├── package.json                       # @madong/monorepo
├── apps/                              # 应用目录
│   ├── admin/                         # @madong/admin - 管理后台
│   │   └── src/
│   │       ├── api/                   # API 接口
│   │       ├── views/                 # 页面视图
│   │       ├── components/            # 组件
│   │       ├── router/               # 路由
│   │       ├── store/                 # 状态管理
│   │       ├── locales/              # 国际化
│   │       ├── adapter/              # 适配器
│   │       ├── layouts/              # 布局
│   │       ├── utils/                # 工具函数
│   │       ├── enums/                # 枚举
│   │       └── types/                # 类型定义
│   ├── platform/                      # @madong/platform - 平台管理
│   ├── install/                       # @madong/install - 安装向导（独立轻量应用）
│   └── backend-mock/                  # @vben/backend-mock
└── packages/                          # Vben 包
    ├── @core/                         # 核心包
    ├── effects/                       # 效果包（request/common-ui/layouts等）
    └── ...
```

## App 包配置规范

```json
// apps/{app}/package.json
{
  "name": "@madong/{app}",
  "version": "5.7.0",
  "type": "module",
  "scripts": {
    "dev": "pnpm vite --mode development",
    "build": "pnpm vite build --mode production",
    "typecheck": "vue-tsc --noEmit --skipLibCheck"
  },
  "imports": {
    "#/*": "./src/*"
  },
  "dependencies": {
    "@vben/access": "catalog:",
    "@vben/common-ui": "catalog:",
    "@vben/request": "catalog:",
    "@vben/stores": "catalog:",
    "@vben/locales": "catalog:",
    "vue": "catalog:",
    "vue-router": "catalog:",
    "pinia": "catalog:",
    "element-plus": "catalog:"
  }
}
```

## 关键约定

- 包名格式：`@madong/{app}`（如 `@madong/admin` / `@madong/platform`）
- 前端框架：Vue 3 + TypeScript + Vben Admin 5
- 构建工具：Vite 6 + Turborepo
- 包管理：pnpm 10 + workspace 协议
- TypeScript 严格模式
- **install 应用特殊**：不依赖 `@vben/*` 包，直接使用 ElementPlus + axios + Pinia

## 检查清单

- [ ] 包名是否使用 `@madong/{app}` 格式
- [ ] `imports` 是否配置了 `#/*` 别名
- [ ] 是否使用了 catalog 协议管理依赖版本
- [ ] install 类型应用是否需要特殊处理（无 Vben 依赖）
