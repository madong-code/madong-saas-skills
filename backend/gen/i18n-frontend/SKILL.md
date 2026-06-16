---
name: madong-gen-i18n-frontend
description: Generate frontend i18n translation files for madong plugin module. Creates JSON translation files with proper key patterns for both zh-cn and en languages.
---

# Step 9: Generate Frontend i18n

Generate JSON translation files for plugin module frontend.

## File Locations

### Three i18n Modes

The system supports three lang file locations with different key generation rules:

| # | Location | Key Generation | Example |
|---|----------|---------------|---------|
| 1 | `apps/{app}/src/lang/{locale}/` | 目录+文件名+文件内key | `system/menu.json` → `system.menu.*` |
| 2 | `plugins/{plugin}/lang/{locale}/` | 插件名+目录+文件名+文件内key | `crud/basic.json` for demo → `demo.crud.basic.*` |
| 3 | `apps/{app}/src/locales/langs/{locale}/` | root模式(文件名=根key) + 目录+文件+key | `common.json` → `common.*`; `system/menu.json` → `system.menu.*` |

### Plugin Mode (插件模式) — 用于此技能生成

```
frontend/admin/src/plugins/{plugin}/lang/zh-cn/{module}/{feature}.json
frontend/admin/src/plugins/{plugin}/lang/en/{module}/{feature}.json
```

**Key prefix**: `{plugin}.{module}.{feature}` (插件名自动由加载器注入)
- ✅ Correct: `demo/lang/zh-cn/crud/basic.json` → key prefix is `demo.crud.basic`
- ❌ Wrong (old style): `demo/lang/zh-cn/crud/crud.basic.json` (冗余前缀)

### Built-in Mode (内置模式) — 应用于主应用

```
frontend/admin/src/lang/zh-cn/{module}/{feature}.json
frontend/admin/src/lang/zh-cn/{module}/{sub}.{feature}.json  (点号文件名，用于深层嵌套)
frontend/admin/src/lang/en/{module}/{feature}.json
frontend/admin/src/lang/en/{module}/{sub}.{feature}.json
```

**Key prefix**: `{module}.{feature}` (NO plugin prefix)
- ✅ Correct: `admin/src/lang/zh-cn/system/menu.json` → key prefix is `system.menu`
- ✅ Correct: `admin/src/lang/zh-cn/system/user.center.json` → key prefix is `system.user.center`
- ❌ Wrong (old style): `admin/src/lang/zh-cn/system/system.menu.json` (冗余前缀)

**Important**: 
- File path itself defines the key prefix (目录与文件名共同参与 key 生成)
- Inside the JSON file, do NOT include the prefix again
- Use nested object structure, NOT dot notation in keys
- Filenames MAY contain dots (`.`), dots in filename also contribute to key hierarchy
- **lang/ 下只保留一级目录**，深层嵌套用点号文件名代替子目录

## Translation File Template (zh-cn)

```json
{
  "dialog_title": "富文本模板",
  "table": {
    "columns": {
      "sort": "排序",
      "title": "标题",
      "template": "模板类型",
      "is_show": "显示状态",
      "status": "状态",
      "created_at": "创建时间"
    }
  },
  "search_form": {
    "title": "标题",
    "template": "模板类型"
  },
  "form": {
    "title": "标题",
    "template": "模板类型",
    "sort": "排序",
    "is_show": "显示状态",
    "enabled": "启用状态",
    "content": "内容",
    "meta": "元数据",
    "extra": "扩展数据"
  },
  "validate": {
    "title_required": "请输入标题",
    "content_required": "请输入内容"
  },
  "tips": {
    "add_success": "添加成功",
    "edit_success": "编辑成功",
    "delete_confirm": "确认删除吗？",
    "delete_success": "删除成功"
  },
  "actions": {
    "add": "新增",
    "edit": "编辑",
    "delete": "删除",
    "detail": "详情",
    "submit": "提交",
    "cancel": "取消",
    "confirm": "确定"
  }
}
```

## Translation File Template (en)

```json
{
  "dialog_title": "Rich Text Template",
  "table": {
    "columns": {
      "sort": "Sort",
      "title": "Title",
      "template": "Template Type",
      "is_show": "Show Status",
      "status": "Status",
      "created_at": "Created At"
    }
  },
  "search_form": {
    "title": "Title",
    "template": "Template Type"
  },
  "form": {
    "title": "Title",
    "template": "Template Type",
    "sort": "Sort",
    "is_show": "Show Status",
    "enabled": "Enabled Status",
    "content": "Content",
    "meta": "Meta Data",
    "extra": "Extra Data"
  },
  "validate": {
    "title_required": "Please enter title",
    "content_required": "Please enter content"
  },
  "tips": {
    "add_success": "Added successfully",
    "edit_success": "Edited successfully",
    "delete_confirm": "Are you sure to delete?",
    "delete_success": "Deleted successfully"
  },
  "actions": {
    "add": "Add",
    "edit": "Edit",
    "delete": "Delete",
    "detail": "Detail",
    "submit": "Submit",
    "cancel": "Cancel",
    "confirm": "Confirm"
  }
}
```

## Usage in Frontend Code

### Plugin Mode

```typescript
import { $t } from '@/locales'

// File: official/lang/zh-cn/rich_text/template.json (目录参与 key 生成)
// Key in file: "dialog_title"
// Full key: official.rich_text.template.dialog_title (插件名由加载器注入)
const title = $t('official.rich_text.template.dialog_title')
const columnLabel = $t('official.rich_text.template.table.columns.title')

// In Vue component
<el-button>{{ $t('official.rich_text.template.actions.add') }}</el-button>
```

### Built-in Mode

```typescript
import { $t } from '@/locales'

// File: admin/src/lang/zh-cn/rich_text/template.json (目录参与 key 生成)
// Key in file: "dialog_title"
// Full key: rich_text.template.dialog_title (NO plugin prefix)
const title = $t('rich_text.template.dialog_title')
const columnLabel = $t('rich_text.template.table.columns.title')

// In Vue component
<el-button>{{ $t('rich_text.template.actions.add') }}</el-button>
```

## Auto-generation Checklist

When generating frontend i18n:
- [ ] Create lang directory structure if not exists: `lang/zh-cn/{module}/` and `lang/en/{module}/`
- [ ] Filename format: `{feature}.json` or `{group}.{feature}.json` (dots in filename contribute to key hierarchy)
- [ ] Generate `zh-cn/{module}/{feature}.json` with nested object structure
- [ ] Generate `en/{module}/{feature}.json` with nested object structure
- [ ] Do NOT include key prefix in JSON content (prefix comes from directory+filename)
- [ ] Add all column labels, placeholders, and validation messages

## Key Naming Convention

### Plugin Mode

| Type | File Location | Key in JSON | Full Key Used in Code |
|------|---------------|-------------|----------------------|
| Title | `plugins/official/lang/zh-cn/rich_text/template.json` | `"dialog_title"` | `official.rich_text.template.dialog_title` |
| Column | `plugins/official/lang/zh-cn/rich_text/template.json` | `"table.columns.title"` (nested) | `official.rich_text.template.table.columns.title` |
| Search | `plugins/official/lang/zh-cn/rich_text/template.json` | `"search_form.title"` (nested) | `official.rich_text.template.search_form.title` |
| Form | `plugins/official/lang/zh-cn/rich_text/template.json` | `"form.title"` (nested) | `official.rich_text.template.form.title` |
| Action | `plugins/official/lang/zh-cn/rich_text/template.json` | `"actions.add"` (nested) | `official.rich_text.template.actions.add` |

### Built-in Mode

| Type | File Location | Key in JSON | Full Key Used in Code |
|------|---------------|-------------|----------------------|
| Title | `admin/src/lang/zh-cn/rich_text/template.json` | `"dialog_title"` | `rich_text.template.dialog_title` |
| Column | `admin/src/lang/zh-cn/rich_text/template.json` | `"table.columns.title"` (nested) | `rich_text.template.table.columns.title` |
| Search | `admin/src/lang/zh-cn/rich_text/template.json` | `"search_form.title"` (nested) | `rich_text.template.search_form.title` |
| Form | `admin/src/lang/zh-cn/rich_text/template.json` | `"form.title"` (nested) | `rich_text.template.form.title` |
| Action | `admin/src/lang/zh-cn/rich_text/template.json` | `"actions.add"` (nested) | `rich_text.template.actions.add` |

## File Naming Rules

1. **Directory & filename together form key prefix**: `{module}/{a}.{b}.json` → key prefix `{module}.{a}.{b}`; `{module}/{feature}.json` → key prefix `{module}.{feature}`
2. **lang/ 下只保留一级目录**，深层嵌套用点号文件名：`system/user/center.json` → `system/user.center.json`
3. **Dots in filename add key segments**: `system/menu.json` = `system.menu.*`; `system.menu.json` = `system.menu.*` (同上)
4. **Module name in directory uses underscore**: `rich_text/template.json` (NOT `rich-text/template.json`)
5. **Feature name in filename uses lowercase**: `template` (NOT `Template`)
6. **File extension**: `.json`
7. **Directory structure**: `lang/{locale}/{module}/{feature}.json` or `lang/{locale}/{module}.{feature}.json`

## Integration with Frontend Code

The generated i18n keys should match the schemas/index.tsx:

```typescript
// schemas/index.tsx
import { $t } from '@/locales'

export const crudSchema = (): CrudSchema => {
  return {
    // File: official/lang/zh-cn/rich_text/template.json
    // Key: "dialog_title"
    dialogTitle: $t('official.rich_text.template.dialog_title'),
    columns: [
      {
        prop: 'title',
        // Key: "table.columns.title"
        label: $t('official.rich_text.template.table.columns.title'),
      },
    ],
    searchFormSchema: {
      schema: [
        {
          // Key: "search_form.title"
          label: $t('official.rich_text.template.search_form.title'),
          prop: 'title',
        },
      ],
    },
    formSchema: {
      schema: [
        {
          // Key: "form.title"
          label: $t('official.rich_text.template.form.title'),
          prop: 'title',
        },
      ],
    },
  }
}
```

## Common Mistakes to Avoid

1. ❌ **Wrong**: Including prefix in JSON keys
   ```json
   {
     "official.rich_text.template.dialog_title": "富文本模板"
   }
   ```

2. ✅ **Correct**: Nested object without prefix
   ```json
   {
     "dialog_title": "富文本模板"
   }
   ```

3. ✅ **Flexible**: Dots in filename OR directory hierarchy (两者等价)
   ```
   lang/zh-cn/rich_text/template.json    →  rich_text.template.* (目录)
   lang/zh-cn/rich_text.template.json    →  rich_text.template.* (点号文件名, 效果同上)
   ```

4. ❌ **Wrong**: Flat keys with dots
   ```json
   {
     "table.columns.sort": "排序"
   }
   ```

5. ✅ **Correct**: Nested objects
   ```json
   {
     "table": {
       "columns": {
         "sort": "排序"
       }
     }
   }
   ```

6. ❌ **Wrong**: 目录名与文件名前缀重复 (目录和文件名中的点号都计入 key)
   ```
   system/system.menu.json   →  `${xxx}.system.system.menu` (冗余的 system)
   ```

7. ✅ **Correct**: 目录名即为第一段 key (多文件模块用目录，单文件用点号)
   ```
   system/menu.json           →  `system.menu.*`
   system.menu.json           →  `system.menu.*` (同上，适合单文件场景)
   ```
