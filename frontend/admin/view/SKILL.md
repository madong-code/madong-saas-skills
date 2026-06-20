---
name: madong-frontend-admin-view
description: Admin 视图层规范，CRUD 页面 + schemas + 10个业务模块
globs:
  - "apps/admin/src/views/**/*.vue"
  - "apps/admin/src/views/**/schemas.ts"
---

## 文件位置

```
apps/admin/src/views/{module}/{name}/
├── index.vue                     # 页面主文件
└── schemas.ts                    # CRUD Schema 定义
```

## 代码模板

```vue
<script setup lang="ts">
import { useCrudSchemas } from '#/components/crud';
import { Page } from '#/components/page';
import { BasicCrud } from '#/components/crud';
import { formDialog } from '#/components/form-dialog';
import { get{Model}List, create{Model}, update{Model}, delete{Model} } from '#/api/{module}/index';
import { schemas } from './schemas';

defineOptions({ name: 'Admin{Model}List' });

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

<style lang="scss" scoped>
//
</style>
```

## 样式约定

- 所有 Vue 组件的 `<style>` 块必须使用 `<style lang="scss" scoped>`
- 避免全局样式污染，列表页样式一律 `scoped`
- 无需自定义样式时可省略 `<style>` 块，默认不生成

## Admin 业务模块

| 模块目录 | API 前缀 | 说明 |
|----------|----------|------|
| `views/system/` | `/system/*` | 系统管理 |
| `views/member/` | `/member/*` | 会员管理 |
| `views/goods/` | `/goods/*` | 商品管理 |
| `views/order/` | `/order/*` | 订单管理 |
| `views/marketing/` | `/marketing/*` | 营销管理 |
| `views/finance/` | `/finance/*` | 财务管理 |
| `views/content/` | `/content/*` | 内容管理 |
| `views/plugin/` | `/plugin/*` | 插件管理 |
| `views/tools/` | `/tools/*` | 工具管理 |
| `views/dashboard/` | `/dashboard` | 仪表盘 |

## 路由 name 规范

```
views/{module}/{name}/index.vue → 路由 name: Admin{Model}List
```

## 关键约定

- 所有 CRUD 页面使用 `BasicCrud + formDialog + schemas` 模式
- schemas 导出 `crudSchema`（表格列）和 `formSchema`（表单字段）
- 组件名前缀统一为 `Admin`
- 工具模块 (`views/tools/`) 包含终端、数据导入等非 CRUD 页面

## 表格列渲染器使用

在 `crudSchema` 中，**状态/开关/字典类字段** 使用 `cellRender` 配置 vxe-table 渲染器：

```typescript
// ✅ 正确用法
import { DictEnum } from '#/enums/dict-enum';

// crudSchema 列定义示例
[
  // 启用/禁用状态 - 使用 CellDictTag + DictEnum
  {
    field: 'enabled',
    title: '状态',
    width: 80,
    cellRender: { name: 'CellDictTag', attrs: { code: DictEnum.SYS_ENABLED_STATUS } },
  },
  // 普通文本列
  {
    field: 'name',
    title: '名称',
    minWidth: 150,
  },
]

// ❌ 错误用法 - viewComponent 模式已废弃
// viewComponent: 'ApiDict',
// viewComponentProps: { code: 'sys_type' },
```

## 检查清单

- [ ] `defineOptions` 是否设置了正确的组件名（Admin 前缀）
- [ ] API 导入路径是否使用 admin 的模块
- [ ] schemas 是否完整（crudSchema + formSchema）
- [ ] 工具类页面是否需要单独处理（非 CRUD 模式）
