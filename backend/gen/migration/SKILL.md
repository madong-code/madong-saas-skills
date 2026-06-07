---
name: madong-gen-migration
description: Generate database migration file for madong module. Supports both app (main project) and plugin targets. Creates migration with proper field types, soft deletes, and indexes following madong conventions. Primary key uses bigInteger for snowflake ID support.
---

# Step 2: Generate Migration

Create database migration file for module.

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
| App | `{prefix}_{module}_{models}` | `ask_questions` |
| Plugin | `{prefix}_{plugin}_{module}_{models}` | `official_ask_questions` |

## Key Features

- **Snowflake ID**: Primary key uses `bigInteger` instead of `id()` for snowflake ID support
- **Soft Deletes**: Always include `deleted_at` field
- **Timestamps**: Use `unsignedInteger` for created_at and updated_at
- **Table Prefix**: Respect system table prefix configuration

## Migration Template (Snowflake ID)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use support\Db;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . '{table_name}';

        // 创建表
        if (!Db::schema()->hasTable($table)) {
            Db::schema()->create($table, function (Blueprint $table) use ($table) {
                $table->comment = '{table_comment}';

                // 主键 - 使用 bigInteger 支持雪花ID
                $table->bigInteger('id')->unsigned()->primary();

                {fields}

                // 软删除
                $table->unsignedInteger('deleted_at')->nullable()->comment('删除时间');

                // 时间戳
                $table->unsignedInteger('created_at')->comment('创建时间');
                $table->unsignedInteger('updated_at')->comment('更新时间');

                // 索引
                {indexes}
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . '{table_name}';

        if (Db::schema()->hasTable($table)) {
            Db::schema()->dropIfExists($table);
        }
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
$table->text('content')->comment('内容');
```

### Integer Fields
```php
$table->unsignedInteger('sort')->default(0)->comment('排序');
$table->unsignedInteger('views')->default(0)->comment('浏览量');
$table->unsignedBigInteger('category_id')->comment('分类ID');
```

### Decimal Field
```php
$table->decimal('price', 10, 2)->default(0)->comment('价格');
$table->decimal('balance', 10, 2)->default(0)->comment('余额');
```

### Boolean Field
```php
$table->boolean('is_recommend')->default(false)->comment('是否推荐');
$table->boolean('is_hot')->default(false)->comment('是否热门');
```

### JSON Field
```php
$table->json('images')->nullable()->comment('图片列表');
$table->json('extra')->nullable()->comment('扩展数据');
```

### Enum Field (using tinyInteger)
```php
$table->tinyInteger('status')->default(1)->comment('状态: 1正常 2禁用');
$table->tinyInteger('type')->default(1)->comment('类型: 1文本 2图片 3视频');
```

### Foreign Key
```php
$table->unsignedBigInteger('category_id')->comment('分类ID');
$table->unsignedBigInteger('user_id')->comment('用户ID');
$table->unsignedBigInteger('parent_id')->nullable()->comment('父级ID');

// 外键约束（可选）
$table->foreign('category_id')->references('id')->on($tablePrefix . 'categories')->onDelete('cascade');
```

### Member ID (for API tables)
```php
$table->unsignedBigInteger('member_id')->comment('会员ID');
$table->index('member_id', '{table}_member_id_index');
```

## Index Types

### Single Index
```php
$table->index('status', '{table}_status_index');
$table->index('category_id', '{table}_category_id_index');
$table->index(['status', 'created_at'], '{table}_status_created_at_index');
```

### Unique Index
```php
$table->unique('name', '{table}_name_unique');
$table->unique(['user_id', 'type'], '{table}_user_type_unique');
```

## Complete Migration Example (App)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use support\Db;

return new class extends Migration
{
    public function up(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . 'ask_questions';

        if (!Db::schema()->hasTable($table)) {
            Db::schema()->create($table, function (Blueprint $table) use ($table) {
                $table->comment = '问答-问题表';

                // 主键 - 使用 bigInteger 支持雪花ID
                $table->bigInteger('id')->unsigned()->primary();

                // 分类ID
                $table->unsignedBigInteger('category_id')->comment('分类ID');
                $table->index('category_id', 'ask_questions_category_id_index');

                // 标题
                $table->string('title', 200)->comment('标题');

                // 内容
                $table->text('content')->comment('内容');

                // 价格
                $table->decimal('price', 10, 2)->default(0)->comment('价格');

                // 浏览量
                $table->unsignedInteger('view_count')->default(0)->comment('浏览量');

                // 状态
                $table->tinyInteger('status')->default(1)->comment('状态: 1正常 2禁用');
                $table->index('status', 'ask_questions_status_index');

                // 软删除
                $table->unsignedInteger('deleted_at')->nullable()->comment('删除时间');

                // 时间戳
                $table->unsignedInteger('created_at')->comment('创建时间');
                $table->unsignedInteger('updated_at')->comment('更新时间');
            });
        }
    }

    public function down(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . 'ask_questions';

        if (Db::schema()->hasTable($table)) {
            Db::schema()->dropIfExists($table);
        }
    }
};
```

## Complete Migration Example (Plugin)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use support\Db;

return new class extends Migration
{
    public function up(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . 'official_ask_questions';

        if (!Db::schema()->hasTable($table)) {
            Db::schema()->create($table, function (Blueprint $table) use ($table) {
                $table->comment = '问答-问题表';

                // 主键 - 使用 bigInteger 支持雪花ID
                $table->bigInteger('id')->unsigned()->primary();

                // 分类ID
                $table->unsignedBigInteger('category_id')->comment('分类ID');
                $table->index('category_id', 'official_ask_questions_category_id_index');

                // 会员ID (可选，用于API数据隔离)
                $table->unsignedBigInteger('member_id')->nullable()->comment('会员ID');
                $table->index('member_id', 'official_ask_questions_member_id_index');

                // 标题
                $table->string('title', 200)->comment('标题');

                // 内容
                $table->text('content')->comment('内容');

                // 价格
                $table->decimal('price', 10, 2)->default(0)->comment('价格');

                // 浏览量
                $table->unsignedInteger('view_count')->default(0)->comment('浏览量');

                // 状态
                $table->tinyInteger('status')->default(1)->comment('状态: 1正常 2禁用');
                $table->index('status', 'official_ask_questions_status_index');

                // 软删除
                $table->unsignedInteger('deleted_at')->nullable()->comment('删除时间');

                // 时间戳
                $table->unsignedInteger('created_at')->comment('创建时间');
                $table->unsignedInteger('updated_at')->comment('更新时间');
            });
        }
    }

    public function down(): void
    {
        $tablePrefix = config('admin.database.table_prefix');
        $table = $tablePrefix . 'official_ask_questions';

        if (Db::schema()->hasTable($table)) {
            Db::schema()->dropIfExists($table);
        }
    }
};
```

## Field Type Mapping

| User Input | Migration Method | Notes |
|------------|------------------|-------|
| string(n) | `string('name', n)` | VARCHAR |
| text | `text('name')` | TEXT |
| integer | `unsignedInteger('name')` | INT UNSIGNED |
| bigint | `unsignedBigInteger('name')` | BIGINT UNSIGNED |
| decimal(m,n) | `decimal('name', m, n)` | DECIMAL |
| tinyint | `tinyInteger('name')` | TINYINT |
| boolean | `boolean('name')` | TINYINT(1) |
| json | `json('name')` | JSON |
| date | `date('name')` | DATE |
| datetime | `dateTime('name')` | DATETIME |
| foreign_key | `unsignedBigInteger('name')` | BIGINT UNSIGNED |

## Naming Convention

| Item | App Convention | Plugin Convention |
|------|---------------|-------------------|
| Table | `{prefix}_{module}_{models}` | `{prefix}_{plugin}_{module}_{models}` |
| Index | `{table}_{column}_index` | `{table}_{column}_index` |
| Foreign Key | (auto) | (auto) |

## Auto-generation Checklist

When generating migration:
- [ ] Use `bigInteger('id')->unsigned()->primary()` instead of `id()`
- [ ] Check table prefix from config
- [ ] Generate timestamp prefix
- [ ] Use correct table name based on target (app/plugin)
- [ ] Add all fields with proper types
- [ ] Add index for foreign keys
- [ ] Add index for status field
- [ ] Add member_id field for API tables
- [ ] Add softDeletes field (deleted_at)
- [ ] Add created_at and updated_at fields
- [ ] Add table comment

## Common Issues

### 1. Duplicate Table
Always check with `hasTable()` before creating:
```php
if (!Db::schema()->hasTable($table)) {
    // create table
}
```

### 2. Index Naming
Keep index names short but descriptive:
```php
// Good
$table->index('category_id', 'questions_category_id_index');

// Bad
$table->index('category_id', 'idx_questions_category_id');
```

### 3. Foreign Key Constraint
Only add foreign key constraints if needed:
```php
// Optional - adds CASCADE delete
$table->foreign('category_id')
      ->references('id')
      ->on($tablePrefix . 'categories')
      ->onDelete('cascade');
```
