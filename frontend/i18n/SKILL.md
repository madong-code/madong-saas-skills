---
name: madong-frontend-i18n
description: 前端国际化规范，JSON 结构 + 加载器
globs:
  - "apps/**/src/locales/**/*.json"
---

## 文件位置

```
apps/{app}/src/locales/
├── index.ts                    # 国际化配置初始化
├── loader/                     # 加载器
└── langs/
    ├── zh_CN.json              # 简体中文
    └── en.json                 # English
```

## JSON 结构

```json
{
  "{module}": {
    "{model}": {
      "{field}": "{翻译文本}"
    }
  }
}
```

### 示例

```json
// zh_CN.json
{
  "system": {
    "menu": {
      "name": "菜单名称",
      "code": "菜单标识",
      "status": "状态",
      "sort": "排序",
      "createTime": "创建时间"
    },
    "role": {
      "name": "角色名称",
      "code": "角色编码"
    }
  },
  "common": {
    "confirm": "确认",
    "cancel": "取消",
    "submit": "提交",
    "reset": "重置",
    "operation": "操作"
  }
}
```

```json
// en.json（key 不变，value 翻译）
{
  "system": {
    "menu": {
      "name": "Name",
      "code": "Code",
      "status": "Status",
      "sort": "Sort",
      "createTime": "Created At"
    }
  }
}
```

## 使用方式

```vue
<template>
  <!-- 在 Vue 模板中使用 $t -->
  <span>{{ $t('system.menu.name') }}</span>
</template>

<script setup lang="ts">
import { $t } from '#/locales';

// 在 JS 中使用
const label = $t('system.menu.name');
</script>
```

## 关键约定

- key 格式：`{module}.{model}.{field}`（同后端 lang 文件）
- zh_CN.json 和 en.json 的 key 结构必须一致
- 翻译文本中可以使用 `{variable}` 插值
- 组件中的静态文本必须使用 `$t()` 而非硬编码
- key 命名使用驼峰（如 `createTime`）
- 每个前端站点（admin/platform）有自己的 locales 目录

## 检查清单

- [ ] key 格式是否为 `{module}.{model}.{field}`
- [ ] zh_CN 和 en 两个文件是否都更新了
- [ ] 组件中的文案是否使用了 `$t()` 而非硬编码
- [ ] key 是否使用驼峰命名
