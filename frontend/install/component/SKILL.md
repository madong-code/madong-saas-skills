---
name: madong-frontend-install-component
description: Install 前端组件规范，6个安装步骤组件
globs:
  - "apps/install/src/components/**/*.vue"
---

## 文件位置

```
apps/install/src/components/
├── agreement-step/            # 步骤1：协议确认
├── environment-step/          # 步骤2：环境检测
├── database-step/             # 步骤3：数据库配置
├── config-step/               # 步骤4：管理员配置
├── tenant-step/               # 步骤5：多租户配置
└── complete-step/             # 步骤6：安装完成
```

## 组件结构

每个步骤组件遵循相同模式：

```vue
<script setup lang="ts">
import { useInstallStore } from '@/store/module/install';

const installStore = useInstallStore();

// 步骤数据绑定到 installStore
// 步骤验证逻辑
</script>

<template>
  <el-form :model="installStore.xxxConfig">
    <!-- 表单字段 -->
  </el-form>
</template>
```

## 安装步骤流程

```
agreement → environment → database → config → tenant → complete
   协议       环境检测     数据库配置   管理员    多租户    完成
```

- 每一步通过 `installStore` 共享状态
- 安装执行通过 SSE 实时获取进度
- 安装完成显示结果和耗时

## 关键约定

- 组件使用 ElementPlus 组件（el-form/el-steps/el-button 等）
- 所有数据绑定到 `useInstallStore`
- 无需 Vben 的 FormDialog / CRUD 组件
- 组件命名使用 kebab-case + `-step` 后缀

## 检查清单

- [ ] 步骤组件是否正确绑定 installStore
- [ ] 是否使用 ElementPlus 组件而非 Vben 组件
- [ ] 步骤顺序是否正确
