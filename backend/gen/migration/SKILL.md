---
name: madong-gen-migration
description: Generate database migration file for madong module. Supports both app (main project) and plugin targets. Creates migration with proper field types, soft deletes, snowflake IDs, and multi-tenant support.
---

# Step 2: Generate Migration

Create database migration file for module.

> **注意**: 基于 portal 实际实现，迁移类使用 `Builder $schema` 模式（不继承 Migration 基类），时间戳使用 `bigInteger`，支持多租户。

## File Location

**App (主项目):**
```
resource/database/migrations/{timestamp}_create_{table_name}_table.php
```

**Plugin (插件):**
```
plugin/{plugin}/resource/database/migrations/{timestamp}_create_{table_name}_table.php
```

## Table Naming Convention

| Target | Table Name | Example |
|--------|------------|---------|
| App | `{prefix}_{module}_{models}` | `portal_ask_questions` |
| Plugin | `{prefix}_{plugin}_{module}_{models}` | `portal_ask_question` |

## Key Features

- **Snowflake ID**: Primary key uses `$table->bigInteger('id')->primary()`
- **Soft Deletes**: `$table->bigInteger('deleted_at')->nullable()`（也使用 bigInteger）
- **Timestamps**: Use `$table->bigInteger()` for created_at/updated_at（与雪花ID一致）
- **Multi-Tenant**: SaaS 环境添加 `tenant_id` 字段
- **Table Prefix**: Respect system table prefix configuration
- **Engine/Charset**: 明确设置 InnoDB + utf8mb4

## Migration Template (基于 portal 实际实现)

```php
<?php

use Illuminate\Database\Schema\Builder;
use Illuminate\Database\Schema\Blueprint;

return new class {

    public function up(Builder $schema): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . '{table_name}';

        if (!$schema->hasTable($table)) {
            $schema->create($table, function (Blueprint $table) {
                $table->bigInteger('id')->primary()->comment('雪花ID主键');

                // 租户隔离（SaaS 环境）
                $table->unsignedBigInteger('tenant_id')->nullable()->index('idx_tenant_id')->comment('租户ID');

                {fields}

                // 软删除
                $table->bigInteger('deleted_at')->nullable()->comment('删除时间');

                // 时间戳
                $table->bigInteger('created_at')->nullable()->comment('创建时间');
                $table->bigInteger('updated_at')->nullable()->comment('更新时间');

                // 索引
                {indexes}

                $table->engine = 'InnoDB';
                $table->charset = 'utf8mb4';
                $table->collation = 'utf8mb4_unicode_ci';
            });
        }
    }

    public function down(Builder $schema): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $schema->dropIfExists($tablePrefix . '{table_name}');
    }
};
```

## Field Types

### String Field
```php
$table->string('name', 100)->comment('名称');
$table->string('email', 255)->unique()->comment('邮箱');
$table->string('cover', 255)->nullable()->comment('封面图');
```

### Text Field
```php
$table->text('description')->nullable()->comment('描述');
$table->longText('content')->comment('长内容');
```

### Integer Fields
```php
$table->integer('sort')->default(0)->comment('排序');
$table->integer('view_count')->default(0)->comment('浏览量');
$table->bigInteger('category_id')->comment('分类ID（雪花ID）');
$table->bigInteger('member_id')->comment('会员ID（雪花ID）');
```

### Decimal Field
```php
$table->decimal('price', 10, 2)->default(0)->comment('价格');
$table->decimal('balance', 10, 2)->default(0)->comment('余额');
```

### Boolean / TinyInt Field
```php
$table->tinyInteger('is_recommend')->default(0)->comment('是否推荐: 0否 1是');
$table->tinyInteger('status')->default(1)->comment('状态: 1正常 0禁用');
```

### Enum Field
```php
$table->enum('target_type', ['question', 'answer', 'comment'])->comment('目标类型');
$table->enum('status', ['pending', 'approved', 'rejected'])->default('pending')->comment('审核状态');
```

### Foreign Key (雪花ID)
```php
$table->bigInteger('category_id')->comment('分类ID');
$table->bigInteger('member_id')->comment('会员ID');
$table->bigInteger('parent_id')->default(0)->comment('父级ID');
```

## Index Types

### Single Index
```php
$table->index('status');
$table->index('created_at');
$table->index('member_id');
$table->index(['status', 'created_at']);
```

### Unique Index
```php
$table->unique('name', 'ask_tag_name_unique');
$table->unique(['member_id', 'question_id'], 'ask_collection_unique');
```

> **注意**: portal 实现中索引使用了描述性的名称，不再使用自动命名。

## Complete Migration Example (Plugin - 基于 portal 实际实现)

```php
<?php

use Illuminate\Database\Schema\Builder;
use Illuminate\Database\Schema\Blueprint;

return new class {

    public function up(Builder $schema): void
    {
        $tablePrefix = config('admin.database.table_prefix');

        // 1. 问答分类表
        $table = $tablePrefix . 'portal_ask_category';
        if (!$schema->hasTable($table)) {
            $schema->create($table, function (Blueprint $table) {
                $table->bigInteger('id')->primary();
                $table->unsignedBigInteger('tenant_id')->nullable()->index('idx_tenant_id')->comment('租户ID');
                $table->string('name', 50)->nullable();
                $table->string('slug', 50)->nullable();
                $table->string('description', 200)->nullable();
                $table->bigInteger('parent_id')->default(0);
                $table->integer('sort')->default(0)->comment('排序');
                $table->tinyInteger('status')->default(1)->comment('状态');
                $table->bigInteger('created_at')->nullable();
                $table->bigInteger('updated_at')->nullable();

                $table->engine = 'InnoDB';
                $table->charset = 'utf8mb4';
                $table->collation = 'utf8mb4_unicode_ci';
            });
        }

        // 2. 问题表
        $table = $tablePrefix . 'portal_ask_question';
        if (!$schema->hasTable($table)) {
            $schema->create($table, function (Blueprint $table) {
                $table->bigInteger('id')->primary()->comment('雪花ID主键');
                $table->unsignedBigInteger('tenant_id')->nullable()->index('idx_tenant_id')->comment('租户ID');
                $table->bigInteger('category_id')->nullable()->comment('分类');
                $table->string('title', 255)->comment('问题标题');
                $table->longText('content')->nullable()->comment('问题内容');
                $table->bigInteger('deleted_at')->nullable()->comment('软删除标记');
                $table->bigInteger('created_at')->nullable()->comment('创建时间');
                $table->bigInteger('updated_at')->nullable()->comment('更新时间');
                $table->integer('view_count')->default(0)->comment('浏览量');
                $table->integer('like_count')->default(0)->comment('点赞数');
                $table->bigInteger('member_id')->comment('提问用户ID');

                $table->index('member_id');
                $table->index('created_at');

                $table->engine = 'InnoDB';
                $table->charset = 'utf8mb4';
                $table->collation = 'utf8mb4_unicode_ci';
            });
        }
    }

    public function down(Builder $schema): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $schema->dropIfExists($tablePrefix . 'portal_ask_question');
        $schema->dropIfExists($tablePrefix . 'portal_ask_category');
    }
};
```

## Field Type Mapping

| User Input | Migration Method | Notes |
|------------|------------------|-------|
| string(n) | `string('name', n)` | VARCHAR |
| text | `text('name')` | TEXT |
| longtext | `longText('name')` | LONGTEXT |
| integer | `integer('name')` | INT |
| bigint | `bigInteger('name')` | BIGINT (雪花ID、时间戳) |
| decimal(m,n) | `decimal('name', m, n)` | DECIMAL |
| tinyint | `tinyInteger('name')` | TINYINT |
| boolean | `boolean('name')` | TINYINT(1) |
| json | `json('name')` | JSON |
| enum | `enum('name', [...])` | ENUM |
| date | `date('name')` | DATE |
| datetime | `dateTime('name')` | DATETIME |
| foreign_key | `bigInteger('name')` | BIGINT (雪花ID外键) |
| tenant_id | `unsignedBigInteger('tenant_id')` | 多租户字段 |

## Naming Convention

| Item | App Convention | Plugin Convention |
|------|---------------|-------------------|
| Table | `{prefix}_{module}_{models}` | `{prefix}_{plugin}_{module}_{models}` |
| Index | Descriptive name or auto | Descriptive name or auto |
| Foreign Key | (auto) | (auto) |

## Auto-generation Checklist

When generating migration:
- [ ] Use `Builder $schema` signature（不继承 Migration 基类）
- [ ] Use `$table->bigInteger('id')->primary()` 替代 `id()` 或 `bigInteger('id')->unsigned()->primary()`
- [ ] Check table prefix from config
- [ ] Generate timestamp prefix
- [ ] Use correct table name based on target (app/plugin)
- [ ] Add `tenant_id` for SaaS multi-tenant support
- [ ] Add all fields with proper types
- [ ] Add index for foreign keys (without auto prefix)
- [ ] Add member_id field for API tables（使用 bigInteger）
- [ ] Add softDeletes field: `$table->bigInteger('deleted_at')->nullable()`
- [ ] Add created_at and updated_at fields（使用 bigInteger）
- [ ] Set engine=InnoDB, charset=utf8mb4, collation=utf8mb4_unicode_ci

## Common Issues

### 1. Duplicate Table
Always check with `hasTable()` before creating:
```php
if (!$schema->hasTable($table)) {
    // create table
}
```

### 2. Timestamp Type
使用 `bigInteger` 而非 `unsignedInteger` 或 `timestamp`：
```php
// Good (portal 实现)
$table->bigInteger('created_at')->nullable()->comment('创建时间');

// Avoid
$table->unsignedInteger('created_at')->comment('创建时间');
```

### 3. Snowflake ID 主键
```php
// Good (portal 实现)
$table->bigInteger('id')->primary()->comment('雪花ID主键');

// Avoid - 不需要 unsigned
$table->bigInteger('id')->unsigned()->primary();
```
