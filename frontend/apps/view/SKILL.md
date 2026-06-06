---
name: madong-frontend-apps-view
description: 视图层规范，CRUD 页面 + schemas
globs:
  - "apps/**/src/views/**/*.vue"
  - "apps/**/src/views/**/schemas.ts"
---

## 文件位置

```
apps/{app}/src/views/{module}/{name}/
├── index.vue                     # 页面主文件
└── schemas.ts                    # CRUD Schema 定义
```

## 代码模板

### index.vue

```vue
<script setup lang="ts">
import { h } from 'vue';
import { useCrudSchemas } from '#/components/crud';
import { Page } from '#/components/page';
import { BasicCrud } from '#/components/crud';
import { formDialog } from '#/components/form-dialog';
import { get{Model}List, create{Model}, update{Model}, delete{Model} } from '#/api/{module}/index';
import { schemas } from './schemas';

defineOptions({ name: '{App}{Model}List' });

const dialogApi = formDialog({
  api: { add: create{Model}, edit: update{Model} },
  schema: () => schemas.formSchema,
});

const crudSchema = useCrudSchemas(schemas.crudSchema);

async function handleDelete(row: {Model}Record) {
  await delete{Model}(row.id);
  // 刷新列表
}
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

### schemas.ts

```typescript
import type { CrudSchema } from '#/components/crud';

export const schemas = {
  // 表格列配置
  crudSchema: [
    { field: 'id', label: 'ID', isSearch: false },
    { field: 'name', label: '名称', isSearch: true },
    { field: 'status', label: '状态', dict: 'data_status', component: 'CellDictTag' },
    { field: 'sort', label: '排序', isSearch: false },
    { field: 'created_at', label: '创建时间', formatter: 'date', isSearch: false },
    { field: 'operation', label: '操作', width: 200 },
  ] as CrudSchema[],

  // 表单配置
  formSchema: [
    { field: 'name', label: '名称', component: 'Input', rules: 'required' },
    { field: 'status', label: '状态', component: 'RadioGroup', defaultValue: 1 },
    { field: 'sort', label: '排序', component: 'InputNumber', defaultValue: 0 },
  ],
};
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{app}` | admin / platform |
| `{module}` | system / member / content / ops / tenant |
| `{name}` | menu / user / article / config |
| `{App}` | Admin / Platform |
| `{Model}` | Menu / Member / Article |
| `{Model}Record` | MenuRecord / MemberRecord |

## 路由 name 规范

```
views/{module}/{name}/index.vue → 路由 name: {App}{Model}List
```

如：`views/system/menu/index.vue` → 路由 name: `AdminMenuList`

## 关键约定

- 每个页面包含 `index.vue` + `schemas.ts` 两个文件
- 页面组件使用 `defineOptions({ name: '{App}{Model}List' })` 设置组件名
- schemas 包含 `crudSchema`（表格列）和 `formSchema`（表单字段）
- 查询字段在 `crudSchema` 中设 `isSearch: true`
- 字典字段使用 `dict: 'data_status'` 指定字典类型
- 操作按钮通过 `CellOperation` 渲染组件实现
- views 目录结构与 api 目录结构一一对应

## 检查清单

- [ ] 是否包含 `index.vue` 和 `schemas.ts`
- [ ] `defineOptions` 是否设置了正确的组件名
- [ ] schemas 中的 crudSchema 和 formSchema 是否完整
- [ ] API 导入路径是否正确
- [ ] 字典字段是否指定了正确的字典类型
