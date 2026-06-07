---
name: madong-gen-i18n-backend
description: Generate backend lang translation files for madong plugin module. Creates PHP translation files with proper key patterns for both zh_CN and en languages.
---

# Step 8: Generate Backend Lang

Generate PHP translation files for plugin module backend.

## File Locations

```
plugin/{plugin}/resource/translations/zh_CN/{module}.php
plugin/{plugin}/resource/translations/en/{module}.php
```

## Translation Key Pattern

Backend i18n uses nested array structure: `{module}.{model}.*`

**Important**:
- PHP file returns nested array structure (NOT dot notation in keys)
- Key prefix `{module}.{model}` is represented as nested array `'{model}' => [...]`
- Do NOT include plugin name in keys

## Translation File Template (zh_CN)

```php
<?php

/**
 * {Module} 多语言文件
 * 插件: {plugin}
 */

return [
    // 通用
    'common' => [
        'success'   => '操作成功',
        'fail'      => '操作失败',
        'delete_success' => '删除成功',
        'delete_fail'    => '删除失败',
        'save_success'   => '保存成功',
        'save_fail'      => '保存失败',
    ],

    // {Model} 相关 - 注意：这里是嵌套数组，不是 'rich_text.template.title'
    '{model}' => [
        'title'      => '{Model}管理',
        'list'       => '{Model}列表',
        'add'        => '添加{Model}',
        'edit'       => '编辑{Model}',
        'delete'     => '删除{Model}',
        'detail'     => '{Model}详情',
        'export'     => '导出{Model}',
        'import'     => '导入{Model}',

        // 字段
        'field' => [
            'id'          => 'ID',
            'name'        => '名称',
            'sort'        => '排序',
            'status'      => '状态',
            'created_at'  => '创建时间',
            'updated_at'  => '更新时间',
        ],

        // 状态
        'status' => [
            'normal'  => '正常',
            'disable' => '禁用',
        ],

        // 验证消息
        'validate' => [
            'name_required' => '请输入名称',
            'name_max'      => '名称最多50个字符',
            'status_required' => '请选择状态',
        ],

        // 搜索表单
        'search' => [
            'name'          => '名称',
            'name_placeholder' => '请输入名称',
            'status'        => '状态',
            'status_placeholder' => '请选择状态',
            'date_range'    => '创建时间',
        ],

        // 操作提示
        'tips' => [
            'add_success'   => '添加{Model}成功',
            'add_fail'     => '添加{Model}失败',
            'edit_success' => '编辑{Model}成功',
            'edit_fail'    => '编辑{Model}失败',
            'delete_confirm' => '确认删除该{Model}吗？',
            'delete_success' => '删除{Model}成功',
            'delete_fail'   => '删除{Model}失败',
        ],
    ],
];
```

## Translation File Template (en)

```php
<?php

/**
 * {Module} Translation File
 * Plugin: {plugin}
 */

return [
    // Common
    'common' => [
        'success'   => 'Operation successful',
        'fail'      => 'Operation failed',
        'delete_success' => 'Deleted successfully',
        'delete_fail'    => 'Delete failed',
        'save_success'   => 'Saved successfully',
        'save_fail'      => 'Save failed',
    ],

    // {Model} Related - Note: nested array structure
    '{model}' => [
        'title'      => '{Model} Management',
        'list'       => '{Model} List',
        'add'        => 'Add {Model}',
        'edit'       => 'Edit {Model}',
        'delete'     => 'Delete {Model}',
        'detail'     => '{Model} Detail',
        'export'     => 'Export {Model}',
        'import'     => 'Import {Model}',

        // Fields
        'field' => [
            'id'          => 'ID',
            'name'        => 'Name',
            'sort'        => 'Sort',
            'status'      => 'Status',
            'created_at'  => 'Created At',
            'updated_at'  => 'Updated At',
        ],

        // Status
        'status' => [
            'normal'  => 'Normal',
            'disable' => 'Disabled',
        ],

        // Validation Messages
        'validate' => [
            'name_required' => 'Please enter name',
            'name_max'      => 'Name cannot exceed 50 characters',
            'status_required' => 'Please select status',
        ],

        // Search Form
        'search' => [
            'name'          => 'Name',
            'name_placeholder' => 'Please enter name',
            'status'        => 'Status',
            'status_placeholder' => 'Please select status',
            'date_range'    => 'Created At',
        ],

        // Operation Tips
        'tips' => [
            'add_success'   => '{Model} added successfully',
            'add_fail'     => 'Failed to add {Model}',
            'edit_success' => '{Model} edited successfully',
            'edit_fail'    => 'Failed to edit {Model}',
            'delete_confirm' => 'Are you sure to delete this {Model}?',
            'delete_success' => '{Model} deleted successfully',
            'delete_fail'   => 'Failed to delete {Model}',
        ],
    ],
];
```

## Usage in Backend Code

```php
// Using trans() helper - key format: {plugin}.{module}.{model}.key
// Plugin name is added by translation system based on file location

echo trans('{plugin}.{module}.{model}.title');
echo trans('{plugin}.{module}.{model}.field.name');

// Example for rich_text template in official plugin:
echo trans('official.rich_text.template.title');
echo trans('official.rich_text.template.field.name');
```

## Auto-generation Checklist

When generating backend i18n:
- [ ] Create `resource/translations/` directory if not exists
- [ ] Generate `zh_CN/{module}.php` with nested array structure
- [ ] Generate `en/{module}.php` with nested array structure
- [ ] Use `'{model}' => [...]` as top-level key (NOT dot notation)
- [ ] Do NOT include plugin name in PHP array keys
- [ ] Add all field labels, validation messages, and tips

## Key Naming Convention

| Type | PHP Array Structure | Full Key Used in Code | Example |
|------|---------------------|----------------------|---------|
| Title | `'{model}' => ['title' => '...']` | `trans('{plugin}.{module}.{model}.title')` | `official.rich_text.template.title` |
| Field | `'{model}' => ['field' => ['name' => '...']]` | `trans('{plugin}.{module}.{model}.field.name')` | `official.rich_text.template.field.name` |
| Status | `'{model}' => ['status' => ['normal' => '...']]` | `trans('{plugin}.{module}.{model}.status.normal')` | `official.rich_text.template.status.normal` |
| Search | `'{model}' => ['search' => ['name' => '...']]` | `trans('{plugin}.{module}.{model}.search.name')` | `official.rich_text.template.search.name` |
| Tips | `'{model}' => ['tips' => ['add_success' => '...']]` | `trans('{plugin}.{module}.{model}.tips.add_success')` | `official.rich_text.template.tips.add_success` |

## Common Mistakes to Avoid

1. ❌ **Wrong**: Using dot notation in PHP array keys
   ```php
   return [
       'rich_text.template.title' => '富文本模板管理',
   ];
   ```

2. ✅ **Correct**: Using nested array structure
   ```php
   return [
       'template' => [
           'title' => '富文本模板管理',
       ],
   ];
   ```

3. ❌ **Wrong**: Including plugin name in keys
   ```php
   return [
       'official' => [
           'rich_text' => [
               'template' => [...]
           ]
       ]
   ];
   ```

4. ✅ **Correct**: Only module and model in keys
   ```php
   return [
       'template' => [...]  // {model} as key
   ];
   // Full key: official.rich_text.template.xxx
   // Plugin and module added by translation system
   ```

## Example: rich_text/template for official plugin

File: `plugin/official/resource/translations/zh_CN/rich_text.php`

```php
<?php

return [
    'common' => [
        'success' => '操作成功',
        'fail' => '操作失败',
    ],
    
    // 'template' is the {model} name
    'template' => [
        'title' => '模板管理',
        'field' => [
            'id' => 'ID',
            'title' => '标题',
            'content' => '内容',
            'sort' => '排序',
        ],
        'search' => [
            'title' => '标题',
        ],
        'tips' => [
            'add_success' => '添加模板成功',
        ],
    ],
];
```

Usage:
```php
trans('official.rich_text.template.title');      // 模板管理
trans('official.rich_text.template.field.title'); // 标题
trans('official.rich_text.template.tips.add_success'); // 添加模板成功
```
