---
name: madong-frontend-shared-component
description: 前端共享公共组件规范，CRUD/FormDialog/渲染组件（admin/platform 共用）
globs:
  - "apps/{admin,platform}/src/components/**/*.vue"
  - "apps/{admin,platform}/src/components/**/*.ts"
---

## 文件位置

```
apps/{admin,platform}/src/components/
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
├── render/                  # 渲染组件 (vxe-table cellRender)
│   └── components/
│       ├── cell-dict/       # 字典单元格
│       ├── cell-dict-tag/   # 字典标签 (通过 DictEnum 编码渲染状态标签)
│       ├── cell-tag/        # 标签单元格
│       ├── cell-switch/     # 开关单元格
│       ├── cell-image/      # 图片单元格
│       ├── cell-link/       # 链接单元格
│       └── cell-operation/  # 操作按钮单元格
├── icon/                    # 图标组件
└── page/                    # 页面组件
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

### 表格列中使用渲染器（推荐方式）

在 schema 的 `crudSchema` 中通过 `cellRender` 配置 vxe-table 渲染器：

```typescript
// ✅ 正确用法 - 使用 cellRender + attrs
{
  field: 'enabled',
  title: '状态',
  width: 80,
  cellRender: { name: 'CellDictTag', attrs: { code: DictEnum.SYS_YES_NO } },
}

// ❌ 错误用法 - 不要直接使用 viewComponent
// viewComponent: 'ApiDict',                ← 不推荐
// viewComponentProps: { code: 'sys_type' }, ← 不推荐
```

常见的字典编码使用 `DictEnum` 枚举：

```typescript
import { DictEnum } from '#/enums/dict-enum';

// 可用编码示例
DictEnum.SYS_ENABLED_STATUS   // 启用/禁用
DictEnum.SYS_YES_NO           // 是/否
DictEnum.SYS_MENU_TYPE        // 菜单类型
```

### 模板中使用（不常用）

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
- **渲染组件的正确用法：在 schema 中通过 `cellRender: { name: '组件名', attrs: {...} }` 配置，不要使用 `viewComponent`**
- admin 和 platform 共享以上基础组件

## 应用差异

| 组件 | admin | platform |
|------|-------|----------|
| 基础组件 (crud/dialog/form/render/icon/page) | ✅ | ✅ |
| `tenant-switch/` | ✅ Admin 特有 | ❌ |
| `notification-drawer/` | ❌ | ✅ Platform 特有 |
| `terminal/` | ✅ Admin 特有 | ❌ |

## 检查清单

- [ ] 新组件是否放在正确的分类目录下
- [ ] 弹窗是否使用 FormDialog 模式
- [ ] 组件命名是否使用大驼峰
- [ ] 复杂组件是否需要导出 `use{ComponentName}` composable
