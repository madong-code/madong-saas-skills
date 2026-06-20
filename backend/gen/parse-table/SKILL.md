---
name: madong-gen-parse-table
description: Parse table definition to extract module name, model name, table name and field definitions. This is the first step in CRUD generation workflow.
---

# Step 1: Parse Table Definition

Extract key information from user-provided table definitions.

## Input Examples

### Example 1: Simple Table
```
Module: Ask
Table: tags
Fields:
- id (primary key)
- name (string, 50, required)
- sort (integer, default 0)
- status (tinyint, default 1)
- created_at (timestamp)
- updated_at (timestamp)
```

### Example 2: Table with Foreign Key
```
Module: Ask
Table: questions
Fields:
- id (primary key)
- category_id (foreign key -> ask.categories)
- title (string, 200, required)
- content (text, required)
- price (decimal 10,2, default 0)
- view_count (integer, default 0)
- status (tinyint, default 1)
- created_at (timestamp)
- updated_at (timestamp)
- deleted_at (timestamp, nullable)
```

### Example 3: Full Definition
```
Module: Market
Table: products
Fields:
- id (primary key)
- category_id (foreign key -> market.categories)
- name (string, 100, required)
- cover (string, 255, nullable) [image]
- price (decimal 10,2, required)
- stock (integer, default 0)
- sales (integer, default 0)
- description (text, nullable)
- content (text, nullable) [editor]
- sort (integer, default 0)
- status (tinyint, default 1)
- created_at (timestamp)
- updated_at (timestamp)
```

## Output Structure

```json
{
  "plugin": "official",
  "module": "ask",
  "model": "Tag",
  "table": "official_ask_tags",
  "fields": [
    {
      "name": "id",
      "type": "id",
      "migration": "idIncrements()"
    },
    {
      "name": "name",
      "type": "string",
      "length": 50,
      "required": true,
      "migration": "string('name', 50)"
    },
    {
      "name": "sort",
      "type": "integer",
      "default": 0,
      "migration": "unsignedInteger('sort')->default(0)"
    },
    {
      "name": "status",
      "type": "tinyint",
      "default": 1,
      "comment": "状态: 1正常 2禁用",
      "migration": "tinyInteger('status')->default(1)"
    },
    {
      "name": "created_at",
      "type": "timestamp",
      "migration": "unsignedInteger('created_at')"
    },
    {
      "name": "updated_at",
      "type": "timestamp",
      "migration": "unsignedInteger('updated_at')"
    },
    {
      "name": "deleted_at",
      "type": "soft_delete",
      "migration": "unsignedInteger('deleted_at')->nullable()"
    }
  ],
  "fillable": ["name", "sort", "status"],
  "casts": {
    "sort": "integer",
    "status": "integer"
  },
  "foreign_keys": []
}
```

## Field Type Mapping

| Input Type | Migration Method | Vue Component |
|------------|------------------|----------------|
| string(n) | `string('x', n)` | `el-input` |
| text | `text('x')` | `el-input (textarea)` |
| integer | `unsignedInteger('x')` | `el-input-number` |
| bigint | `unsignedBigInteger('x')` | `el-input-number` |
| decimal(m,n) | `decimal('x', m, n)` | `el-input-number` |
| tinyint | `tinyInteger('x')` | 表格列: `cellRender: { name: 'CellDictTag', attrs: { code: DictEnum.SYS_XXX } }`; 表单: `ApiDict` |
| foreign_key | `unsignedBigInteger('x')` | `ApiSelect` |
| date | `date('x')` | `DatePicker` |
| datetime | `dateTime('x')` | `DateTimePicker` |
| json | `json('x')` | `el-input` |
| image | `string('x', 255)` | `ImageUpload` |
| boolean | `boolean('x')` | `el-switch` |

## Naming Convention

| Item | Convention | Example |
|------|------------|---------|
| Plugin | snake_case | `official`, `market` |
| Module | PascalCase | `Ask`, `Market`, `Question` |
| Model | PascalCase singular | `Tag`, `Product`, `Question` |
| Table | snake_case with prefix | `official_ask_tags` |
| Field | snake_case | `user_name`, `created_at` |

## Field Attributes

Each field should have these attributes:

- `name`: Field name in snake_case
- `type`: Field type (string, integer, text, etc.)
- `length`: Optional length for string type
- `required`: Whether field is required
- `default`: Default value
- `nullable`: Whether field can be null
- `comment`: Field comment
- `migration`: Migration method call
- `fillable`: Whether in $fillable array
- `casts`: Type casting for model

## Validation Rules

Generate validation rules based on field attributes:

| Attribute | Validation |
|-----------|------------|
| required | `['required', 'max:255']` |
| string | `['string', 'max:255']` |
| integer | `['integer']` |
| decimal | `['numeric']` |
| email | `['email']` |
| unique | `['unique:table,column']` |

## Auto-generation Checklist

When parsing table definition:
- [ ] Extract plugin name
- [ ] Extract module name (PascalCase)
- [ ] Extract model name (PascalCase singular)
- [ ] Generate table name with prefix
- [ ] Parse each field with full attributes
- [ ] Generate fillable array
- [ ] Generate casts array
- [ ] Identify foreign key relationships
