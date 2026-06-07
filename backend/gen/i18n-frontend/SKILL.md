---
name: madong-gen-i18n-frontend
description: Generate frontend i18n translation files for madong plugin module. Creates JSON translation files with proper key patterns for both zh-cn and en languages.
---

# Step 9: Generate Frontend i18n

Generate JSON translation files for plugin module frontend.

## File Locations

### Plugin Mode (插件模式)

```
frontend/admin/src/apps/{plugin}/lang/zh-cn/{module}.{feature}.json
frontend/admin/src/apps/{plugin}/lang/en/{module}.{feature}.json
```

**Key prefix**: `{plugin}.{module}.{feature}`
- Example: `official/lang/zh-cn/rich_text.template.json` → key prefix is `official.rich_text.template`

### Built-in Mode (内置模式)

```
frontend/admin/src/lang/zh-cn/{module}.{feature}.json
frontend/admin/src/lang/en/{module}.{feature}.json
```

**Key prefix**: `{module}.{feature}` (NO plugin prefix)
- Example: `admin/src/lang/zh-cn/rich_text.template.json` → key prefix is `rich_text.template`

**Important**: 
- File path itself defines the key prefix
- Inside the JSON file, do NOT include the prefix again
- Use nested object structure, NOT dot notation in keys

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

// File: official/lang/zh-cn/rich_text.template.json
// Key in file: "dialog_title"
// Full key: official.rich_text.template.dialog_title
const title = $t('official.rich_text.template.dialog_title')
const columnLabel = $t('official.rich_text.template.table.columns.title')

// In Vue component
<el-button>{{ $t('official.rich_text.template.actions.add') }}</el-button>
```

### Built-in Mode

```typescript
import { $t } from '@/locales'

// File: admin/src/lang/zh-cn/rich_text.template.json
// Key in file: "dialog_title"
// Full key: rich_text.template.dialog_title (NO plugin prefix)
const title = $t('rich_text.template.dialog_title')
const columnLabel = $t('rich_text.template.table.columns.title')

// In Vue component
<el-button>{{ $t('rich_text.template.actions.add') }}</el-button>
```

## Auto-generation Checklist

When generating frontend i18n:
- [ ] Create lang directory structure if not exists: `lang/zh-cn/` and `lang/en/`
- [ ] Filename format: `{module}.{feature}.json` (e.g., `rich_text.template.json`)
- [ ] Generate `zh-cn/{module}.{feature}.json` with nested object structure
- [ ] Generate `en/{module}.{feature}.json` with nested object structure
- [ ] Do NOT include key prefix in JSON content (prefix comes from filename)
- [ ] Add all column labels, placeholders, and validation messages

## Key Naming Convention

### Plugin Mode

| Type | File Location | Key in JSON | Full Key Used in Code |
|------|---------------|-------------|----------------------|
| Title | `apps/official/lang/zh-cn/rich_text.template.json` | `"dialog_title"` | `official.rich_text.template.dialog_title` |
| Column | `apps/official/lang/zh-cn/rich_text.template.json` | `"table.columns.title"` (nested) | `official.rich_text.template.table.columns.title` |
| Search | `apps/official/lang/zh-cn/rich_text.template.json` | `"search_form.title"` (nested) | `official.rich_text.template.search_form.title` |
| Form | `apps/official/lang/zh-cn/rich_text.template.json` | `"form.title"` (nested) | `official.rich_text.template.form.title` |
| Action | `apps/official/lang/zh-cn/rich_text.template.json` | `"actions.add"` (nested) | `official.rich_text.template.actions.add` |

### Built-in Mode

| Type | File Location | Key in JSON | Full Key Used in Code |
|------|---------------|-------------|----------------------|
| Title | `admin/src/lang/zh-cn/rich_text.template.json` | `"dialog_title"` | `rich_text.template.dialog_title` |
| Column | `admin/src/lang/zh-cn/rich_text.template.json` | `"table.columns.title"` (nested) | `rich_text.template.table.columns.title` |
| Search | `admin/src/lang/zh-cn/rich_text.template.json` | `"search_form.title"` (nested) | `rich_text.template.search_form.title` |
| Form | `admin/src/lang/zh-cn/rich_text.template.json` | `"form.title"` (nested) | `rich_text.template.form.title` |
| Action | `admin/src/lang/zh-cn/rich_text.template.json` | `"actions.add"` (nested) | `rich_text.template.actions.add` |

## File Naming Rules

1. **Module name in filename uses underscore**: `rich_text.template.json` (NOT `rich-text.template.json`)
2. **Feature name in filename uses lowercase**: `template` (NOT `Template`)
3. **File extension**: `.json`
4. **Directory structure**: `lang/{locale}/{module}.{feature}.json`

## Integration with Frontend Code

The generated i18n keys should match the schemas/index.tsx:

```typescript
// schemas/index.tsx
import { $t } from '@/locales'

export const crudSchema = (): CrudSchema => {
  return {
    // File: official/lang/zh-cn/rich_text.template.json
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

3. ❌ **Wrong**: Using hyphen in filename
   ```
   lang/zh-cn/rich-text.template.json
   ```

4. ✅ **Correct**: Using underscore in filename
   ```
   lang/zh-cn/rich_text.template.json
   ```

5. ❌ **Wrong**: Flat keys with dots
   ```json
   {
     "table.columns.sort": "排序"
   }
   ```

6. ✅ **Correct**: Nested objects
   ```json
   {
     "table": {
       "columns": {
         "sort": "排序"
       }
     }
   }
   ```
