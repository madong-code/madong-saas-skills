---
name: madong-frontend-component
description: 公共组件规范，FormDialog/CRUD表格/渲染组件
globs:
  - "apps/**/src/components/**/*.vue"
  - "apps/**/src/components/**/*.ts"
---

## 文件位置

```
apps/{app}/src/components/
├── crud/                    # CRUD 组件
│   ├── crud.vue
│   ├── types.ts
│   ├── use-crud.ts
│   └── components/
│       ├── dialog/          # CRUD 弹窗
│       ├── table-action/    # 表格操作按钮
│       └── viewer/          # 查看器
├── dialog/                  # 通用弹窗
│   ├── dialog.vue
│   └── use-dialog.ts
├── form/                    # 表单组件
│   ├── component-map.ts
│   └── components/
│       ├── api-select/      # API 选择器
│       ├── api-dict/        # 字典选择器
│       └── ...
├── render/                  # 渲染组件
│   └── components/
│       ├── cell-dict/       # 字典单元格
│       ├── cell-tag/        # 标签单元格
│       ├── cell-switch/     # 开关单元格
│       ├── cell-image/      # 图片单元格
│       ├── cell-link/       # 链接单元格
│       └── cell-operation/  # 操作按纽单元格
├── icon/                    # 图标组件
├── page/                    # 页面组件
└── tenant-switch/           # 租户切换（admin 特有）
```

## FormDialog 组件

使用 `components/form-dialog/` 的 `useFormDialog` composable：

```typescript
import { useFormDialog } from '#/components/form-dialog';

const dialogApi = useFormDialog({
  api: { add: createMenu, edit: updateMenu },
  schema: () => [
    { field: 'name', label: '名称', component: 'Input', rules: 'required' },
    { field: 'status', label: '状态', component: 'RadioGroup', rules: 'required' },
  ],
});

// 打开新增/编辑/查看
dialogApi.openAdd();
dialogApi.openEdit({ id: 1, name: '菜单1' });
dialogApi.openView({ id: 1 });
```

## CRUD 组件

```vue
<template>
  <Page>
    <BasicCrud
      :api="getMenuList"
      :schemas="schemas"
      :dialog-api="dialogApi"
      @add="dialogApi.openAdd()"
      @edit="dialogApi.openEdit(row)"
    />
  </Page>
</template>
```

## 渲染组件

```vue
<!-- 字典标签 -->
<CellDict :value="row.status" :options="statusOptions" />
<!-- 开关 -->
<CellSwitch :value="row.enabled" @change="handleChange" />
<!-- 操作按钮 -->
<CellOperation :actions="actions" />
```

## 关键约定

- 公共组件放在 `components/` 目录下，按功能分类
- FormDialog 是推荐的弹窗表单方案，优先使用 `useFormDialog`
- CRUD 组件基于 Vben 的 `BasicTable` 封装
- 渲染组件用于列表列中格式化显示，不单独使用
- admin 和 platform 共享相同的组件结构

## 检查清单

- [ ] 新组件是否放在正确的分类目录下
- [ ] 弹窗是否使用 FormDialog 模式
- [ ] 组件命名是否使用大驼峰
- [ ] 复杂组件是否需要导出 `use{ComponentName}` composable
