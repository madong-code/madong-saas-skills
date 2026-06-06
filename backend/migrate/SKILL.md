---
name: madong-backend-migrate
description: 数据库迁移规范，定义表结构、字段、索引
globs:
  - "database/migrations/**/*.php"
---

## 文件位置

```
database/migrations/{version}_{prefix}_{module}_{table}.php
```

## 命名规范

| 部分 | 格式 | 示例 |
|------|------|------|
| 版本号 | `YYYY_MM_DD_HHMMSS` | `2024_01_01_000001` |
| 表前缀 | `{prefix}` | `system_` / `member_` / `log_` |
| 模块 | `{module}` | system / member / content |
| 表名 | `{table}` | menu / user / article |

完整示例：`2024_01_01_000001_system_menu.php`

## 代码模板

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 运行迁移
     */
    public function up(): void
    {
        Schema::create('system_menu', function (Blueprint $table) {
            // 主键（雪花ID）
            $table->bigInteger('id')->primary()->unsigned()->comment('ID');

            // 关联字段
            $table->bigInteger('pid')->default(0)->comment('上级ID');
            $table->bigInteger('created_by')->default(0)->comment('创建者');

            // 内容字段
            $table->string('name', 100)->comment('名称');
            $table->string('code', 50)->unique()->comment('标识');
            $table->string('icon', 100)->nullable()->comment('图标');

            // 状态字段
            $table->tinyInteger('status')->default(1)->comment('状态 1-开启 0-关闭');

            // 排序
            $table->integer('sort')->default(0)->comment('排序');

            // 时间戳
            $table->unsignedInteger('created_at')->comment('创建时间');
            $table->unsignedInteger('updated_at')->comment('更新时间');

            // 软删除
            $table->softDeletes();

            // 索引
            $table->index('pid');
            $table->index('status');
            $table->index('sort');
        });
    }

    /**
     * 回滚迁移
     */
    public function down(): void
    {
        Schema::dropIfExists('system_menu');
    }
};
```

## 字段类型映射

| 迁移方法 | 说明 | 对应 PHP 类型 |
|----------|------|--------------|
| `$table->bigInteger('id')` | 大整数（雪花ID主键） | int |
| `$table->integer('sort')` | 整数 | int |
| `$table->tinyInteger('status')` | 小整数 | int |
| `$table->string('name', 100)` | 字符串 | string |
| `$table->text('content')` | 长文本 | string |
| `$table->decimal('price', 10, 2)` | 小数 | float |
| `$table->json('extra')` | JSON | array |
| `$table->unsignedInteger('created_at')` | 时间戳 | int |

## 关键约定

- 主键统一使用 `bigInteger`，支持雪花ID
- 时间戳使用 `unsignedInteger` 存储 Unix 时间戳（非 datetime）
- 软删除使用 `$table->softDeletes()`（`deleted_at` 字段）
- 所有字段必须加 `->comment('中文描述')`
- 外键关联字段使用 `bigInteger` 类型
- 索引：常用查询字段加 `->index()`，唯一字段加 `->unique()`
- 表前缀分模块：`system_` / `member_` / `tenant_` / `log_` / `dict_` / `crontab_`
- 每个迁移文件只操作一张表
- 迁移必须实现 `up()` 和 `down()` 方法

## 检查清单

- [ ] 文件名是否符合 `{version}_{prefix}_{module}_{table}.php` 格式
- [ ] 主键是否使用 `bigInteger` + `unsigned`
- [ ] 是否所有字段都有 `->comment()`
- [ ] 时间戳是否使用 `unsignedInteger` 而非 `timestamps()`
- [ ] 软删除是否使用 `softDeletes()`
- [ ] 是否添加了必要的索引
- [ ] `down()` 方法是否实现了回滚
