---
name: madong-frontend-platform-view
description: Platform 视图层规范，CRUD 页面 + schemas + 6个业务模块
globs:
  - "apps/platform/src/views/**/*.vue"
  - "apps/platform/src/views/**/schemas.ts"
---

## 文件位置

```
apps/platform/src/views/{module}/{name}/
├── index.vue                     # 页面主文件
└── schemas.ts                    # CRUD Schema 定义
```

## 代码模板

与 Admin 的 view 模板结构完全一致，仅 `defineOptions` 前缀不同：

```vue
<script setup lang="ts">
import { useCrudSchemas } from '#/components/crud';
import { Page } from '#/components/page';
import { BasicCrud } from '#/components/crud';
import { formDialog } from '#/components/form-dialog';
import { get{Model}List, create{Model}, update{Model}, delete{Model} } from '#/api/{module}/index';
import { schemas } from './schemas';

defineOptions({ name: 'Platform{Model}List' });

const dialogApi = formDialog({
  api: { add: create{Model}, edit: update{Model} },
  schema: () => schemas.formSchema,
});

const crudSchema = useCrudSchemas(schemas.crudSchema);
</script>

<template>
  <Page>
    <BasicCrud
      :api="get{Model}List"
      :schemas="crudSchema"
      :dialog-api="dialogApi"
      @add="dialogApi.openAdd()"
      @edit="dialogApi.openEdit(row)"
    />
  </Page>
</template>
```

## Platform 业务模块

| 模块目录 | API 前缀 | 说明 |
|----------|----------|------|
| `views/system/` | `/system/*` | 系统管理 |
| `views/tenant/` | `/tenant/*` | 租户管理 |
| `views/plugin/` | `/plugin/*` | 插件管理 |
| `views/database/` | `/database/*` | 数据库管理 |
| `views/monitor/` | `/monitor/*` | 监控管理 |
| `views/dashboard/` | `/dashboard` | 仪表盘 |

## 路由 name 规范

```
views/{module}/{name}/index.vue → 路由 name: Platform{Model}List
```

## 关键约定

- 页面结构与 Admin 完全一致，仅组件名前缀为 `Platform`
- schemas 格式与 Admin 相同
- 业务模块少于 Admin（6 vs 10），聚焦平台运维

## 检查清单

- [ ] `defineOptions` 是否设置了正确的组件名（Platform 前缀）
- [ ] API 导入路径是否使用 platform 的模块
- [ ] schemas 是否完整
