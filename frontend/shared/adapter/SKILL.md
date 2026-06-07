---
name: madong-frontend-shared-adapter
description: 前端共享适配器规范，Vben 应用（admin/platform）的 CRUD/vxe-table/组件映射
globs:
  - "apps/{admin,platform}/src/adapter/**/*.ts"
---

## 文件位置

```
apps/{admin,platform}/src/adapter/
├── form.ts                    # VbenForm 适配器
├── vxe-table.ts               # VxeTable 表格适配器
├── component/
│   └── index.ts               # 组件适配器（ElementPlus 组件注册）
└── crud/
    └── index.ts               # CRUD 组件导出
```

## 各适配器说明

### form.ts - 表单适配器

```typescript
import { useVbenForm } from '@vben/common-ui';

export { useVbenForm };

// 表单 schema 扩展（支持 viewComponent 详情展示）
export interface VbenFormSchema {
  // 默认 useVbenForm 的 schema 属性
  // 可扩展 viewComponent 用于详情展示
}
```

### vxe-table.ts - 表格适配器

```typescript
import { useVbenVxeGrid } from '@vben/common-ui';

export { useVbenVxeGrid };

// 配置表格样式、代理、渲染器
```

### component/index.ts - 组件映射

```typescript
import { globalShareState } from '@vben/common-ui';

// 注册 Element Plus 组件到全局组件系统
const componentMap: Record<string, Component> = {
  ApiDict, ApiSelect, ApiTreeSelect, ApiCascader,
  Input, InputNumber, Textarea, DatePicker,
  Editor, IconPicker, ImagePicker, Upload,
  // ...
};

globalShareState.setComponents(componentMap);
```

## 关键约定

- 适配器负责连接 Vben 框架与业务组件
- `form.ts` 统一管理表单验证规则（required/selectRequired）
- `component/index.ts` 注册 Element Plus 组件至全局组件系统
- CRUD 适配器导出：`Crud` 组件、`useCrud` hooks、类型定义
- admin 和 platform 使用相同的适配器代码
- **install 不使用此适配器**，直接使用 ElementPlus

## 检查清单

- [ ] 组件映射是否包含了所有使用的组件类型
- [ ] 表单验证规则是否配置正确
- [ ] vxe-table 渲染器是否与项目版本兼容
