---
name: madong-backend-model
description: Eloquent 模型规范，继承 BaseModel，支持雪花ID/软删除/多租户
globs:
  - "app/**/model/**/*.php"
---

## 文件位置

```
app/model/{module}/{Model}.php
```

模型层是跨端共享的，不分 admin/platform/api。

## 基类说明

### BaseModel (`core\foundation\base\BaseModel`)

```php
abstract class BaseModel extends Model
{
    // 默认配置
    public $incrementing = false;          // 雪花ID，不自增
    protected $keyType = 'int';            // 主键类型
    protected $dateFormat = 'U';           // 时间戳格式：Unix时间戳
    const CREATED_AT = 'created_at';       // 创建时间字段
    const UPDATED_AT = 'updated_at';       // 更新时间字段
}
```

### 常用 trait

| trait | 说明 |
|-------|------|
| `Illuminate\Database\Eloquent\SoftDeletes` | 软删除 |
| `app\model\traits\VariousHasRelations` | 多态关联 |
| `app\model\traits\ResolveRelationsUseContainer` | 容器解析关联 |

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\model\{module};

use app\model\traits\VariousHasRelations;
use core\foundation\base\BaseModel;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class {Model} extends BaseModel
{
    use SoftDeletes;
    use VariousHasRelations;

    // 表名（默认自动根据类名生成）
    protected $table = 'system_menu';

    // 类型转换
    protected $casts = [
        'id'         => 'integer',
        'pid'        => 'integer',
        'sort'       => 'integer',
        'status'     => 'integer',
        'created_at' => 'integer',
        'updated_at' => 'integer',
    ];

    // 追加字段
    protected $appends = [];

    // 不可批量赋值字段
    protected $guarded = [];

    // 关联关系
    public function parent(): BelongsTo
    {
        return $this->belongsTo(__CLASS__, 'pid', 'id');
    }

    public function children(): HasMany
    {
        return $this->hasMany(__CLASS__, 'pid', 'id');
    }
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system/member/content/ops/tenant/sync 等 |
| `{Model}` | Menu/Member/Article/Config 等 |
| `{table}` | system_menu/member_user/log_operation 等 |

## 字段类型映射

| PHP类型 | $casts 值 | 数据库类型 |
|---------|-----------|-----------|
| int | `'integer'` | BIGINT/INT |
| string | `'string'` | VARCHAR |
| float | `'float'` | DECIMAL |
| bool | `'boolean'` | TINYINT |
| array | `'array'` | JSON |
| object | `'object'` | JSON |

## 关键约定

- 默认使用雪花ID（`$incrementing = false`），不自增主键
- 时间戳使用 Unix 时间戳（`$dateFormat = 'U'`），字段名 `created_at`/`updated_at`
- 软删除使用 `SoftDeletes` trait，删除时间字段 `deleted_at`
- 所有关联关系必须显式声明方法返回类型（`: BelongsTo` / `: HasMany`）
- 模型属性类型转换必须使用 `$casts` 属性
- 批量赋值防护使用 `$guarded = []`（白名单模式），或 `$fillable`（黑名单模式）
- 多租户使用 `TenantScope` 自动过滤，无需在每个模型中手动添加 where 条件
- `morph_map` 多态映射在 `config/morph_map.php` 中配置，通过 `MorphMapBootstrap` 注册
- 如需使用容器解析关联，使用 `ResolveRelationsUseContainer` trait

## 检查清单

- [ ] `$table` 是否指定了正确的表名
- [ ] 主键配置：`$incrementing = false` + `$keyType = 'int'`
- [ ] 时间戳格式是否正确：`$dateFormat = 'U'`
- [ ] `$casts` 是否覆盖了所有需要类型转换的字段
- [ ] 关联关系是否声明了返回类型
- [ ] 软删除是否正确引入了 `SoftDeletes` trait
- [ ] 命名空间是否正确（`app\model\{module}`）
