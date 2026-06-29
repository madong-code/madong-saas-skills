---
name: madong-gen-model
description: Generate Eloquent model for madong module. Supports both app (main project) and plugin targets. Creates model with SoftDeletes, relationships, and standard CRUD methods.
---

# Step 3: Generate Model

Create Eloquent model file for module.

## File Location

**App (主项目):**
```
app/model/{module}/{Model}.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/model/{module}/{Model}.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{base_model}` | `core\foundation\base\BaseModel` | `plugin\{Plugin}\app\model\BaseModel` |

## Model Template

```php
<?php

declare(strict_types=1);
/**
 *+------------------
 * madong
 *+------------------
 * Copyright (c) https://gitee.com/motion-code All rights reserved.
 *+------------------
 * Author: Mr. April (405784684@qq.com)
 *+------------------
 */

namespace {ns}\model\{module};

use {base_model};
use {ns}\model\{module}\{RelatedModel};
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * {Model}模型类
 *
 * Class {Model}
 */
class {Model} extends BaseModel
{
    /**
     * 启用软删除
     */
    use SoftDeletes;

    /**
     * 数据表名称
     */
    protected $table = '{table_name}';

    /**
     * 数据表主键
     */
    protected $primaryKey = 'id';

    /**
     * 是否自增（雪花ID 设为 false）
     */
    public $incrementing = false;

    /**
     * 可批量赋值的字段
     */
    protected $fillable = [
        {fillable}
    ];

    /**
     * 隐藏字段
     */
    protected $hidden = [
        {hidden}
    ];

    /**
     * 类型转换（雪花ID 类型设为 string）
     */
    protected $casts = [
        {casts}
    ];

    /**
     * 追加字段
     */
    protected $appends = [
        {appends}
    ];

    /**
     * 获取{related}关联
     */
    public function {related}(): \Illuminate\Database\Eloquent\Relations\{RelationType}
    {
        return $this->{relationMethod}({RelatedModel}::class, '{foreign_key}', '{owner_key}');
    }

    /**
     * 设置密码（自动hash）
     */
    public function setPasswordAttribute($value): void
    {
        $this->attributes['password'] = password_hash($value, PASSWORD_DEFAULT);
    }

    /**
     * 验证密码
     */
    public function verifyPassword($password): bool
    {
        return password_verify($password, $this->password);
    }
}
```

## Complete Example (App)

```php
<?php

declare(strict_types=1);
/**
 *+------------------
 * madong
 *+------------------
 * Copyright (c) https://gitee.com/motion-code All rights reserved.
 *+------------------
 * Author: Mr. April (405784684@qq.com)
 *+------------------
 */

namespace app\model\member;

use app\enum\common\EnabledStatus;
use app\enum\system\Sex;
use core\base\BaseModel;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * 会员模型
 *
 * Class Member
 */
class Member extends BaseModel
{
    /**
     * 启用软删除
     */
    use SoftDeletes;

    /**
     * 数据表名称
     */
    protected $table = 'member';

    /**
     * 数据表主键
     */
    protected $primaryKey = 'id';

    protected static function booted(): void
    {
        // Custom boot logic
    }

    /**
     * 可批量赋值的字段
     */
    protected $fillable = [
        'id',
        'username',
        'email',
        'phone',
        'password',
        'nickname',
        'avatar',
        'level_id',
        'points',
        'balance',
        'gender',
        'birthday',
        'last_login_time',
        'last_login_ip',
        'login_count',
        'enabled',
        'created_at',
        'updated_at',
        'deleted_at',
        'bio'
    ];

    /**
     * 隐藏字段
     */
    protected $hidden = [
        'password',
    ];

    /**
     * 追加字段
     */
    protected $appends = [
        'gender_text',
        'enabled_text',
    ];

    /**
     * 获取性别文本
     */
    public function getGenderTextAttribute(): string
    {
        return Sex::tryFrom($this->gender)?->label() ?? '未知';
    }

    /**
     * 获取状态文本
     */
    public function getEnabledTextAttribute(): string
    {
        return EnabledStatus::tryFrom($this->enabled)?->label() ?? '未知';
    }

    /**
     * 关联会员等级
     */
    public function level(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(MemberLevel::class, 'level_id', 'id');
    }

    /**
     * 关联会员标签
     */
    public function tags(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(MemberTag::class, MemberTagRelation::class, 'member_id', 'tag_id');
    }

    /**
     * 关联签到记录
     */
    public function signRecords(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(MemberSign::class, 'member_id', 'id');
    }

    /**
     * 设置密码
     */
    public function setPasswordAttribute($value): void
    {
        $this->attributes['password'] = password_hash($value, PASSWORD_DEFAULT);
    }

    /**
     * 验证密码
     */
    public function verifyPassword($password): bool
    {
        return password_verify($password, $this->password);
    }
}
```

## Complete Example (Plugin - 基于 portal 实际实现)

```php
<?php

declare(strict_types=1);
/**
 *+------------------
 * madong
 *+------------------
 * Copyright (c) https://gitee.com/motion-code  All rights reserved.
 *+------------------
 * Author: Mr. April (405784684@qq.com)
 *+------------------
 * Official Website: http://www.madong.tech
 */

namespace plugin\portal\app\model\question;

use plugin\portal\app\model\BaseModel;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * 问题模型
 */
class Question extends BaseModel
{
    use SoftDeletes;

    protected $table = 'portal_ask_question';

    protected $fillable = [
        'id', 'category_id', 'title', 'content', 'view_count', 'like_count',
        'collect_count', 'comment_count', 'member_id', 'is_sticky',
        'sticky_order', 'is_excellent', 'is_solved', 'solved_answer_id',
        'created_at', 'updated_at',
    ];

    protected $casts = [
        'id'               => 'string',     // 雪花ID
        'category_id'      => 'string',     // 雪花ID
        'view_count'       => 'integer',
        'like_count'       => 'integer',
        'collect_count'    => 'integer',
        'comment_count'    => 'integer',
        'member_id'        => 'string',     // 雪花ID
        'is_sticky'        => 'integer',
        'sticky_order'     => 'integer',
        'is_excellent'     => 'integer',
        'is_solved'        => 'integer',
        'solved_answer_id' => 'string',     // 雪花ID
        'created_at'       => 'integer',
        'updated_at'       => 'integer',
        'deleted_at'       => 'integer',
    ];

    public function category(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id', 'id');
    }

    public function answers(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Answer::class, 'question_id', 'id');
    }

    public function tags(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(Tag::class, QuestionTag::class, 'question_id', 'tag_id');
    }
}
```

## Relationship Types

### BelongsTo (belongs_to)
```php
/**
 * 获取所属分类
 */
public function category(): \Illuminate\Database\Eloquent\Relations\BelongsTo
{
    return $this->belongsTo(Category::class, 'category_id', 'id');
}
```

### HasMany (has_many)
```php
/**
 * 获取评论列表
 */
public function comments(): \Illuminate\Database\Eloquent\Relations\HasMany
{
    return $this->hasMany(Comment::class, 'question_id', 'id');
}
```

### BelongsToMany (many_to_many)
```php
/**
 * 获取标签列表
 */
public function tags(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
{
    return $this->belongsToMany(
        Tag::class,
        MemberTagRelation::class,  // 中间表模型
        'member_id',               // 当前模型在中间表的关联键
        'tag_id'                   // 另一模型在中间表的关联键
    );
}
```

### HasOne (has_one)
```php
/**
 * 获取主图
 */
public function cover(): \Illuminate\Database\Eloquent\Relations\HasOne
{
    return $this->hasOne(Image::class, 'question_id', 'id');
}
```

## Cast Types

| Type | Example | Notes |
|------|---------|-------|
| string | `'id' => 'string'` | **雪花ID 必须用 string** |
| integer | `'view_count' => 'integer'` | |
| float | `'price' => 'float'` | |
| decimal | `'price' => 'decimal:2'` | |
| boolean | `'is_hot' => 'boolean'` | |
| string | `'name' => 'string'` | |
| array | `'data' => 'array'` | |
| object | `'data' => 'object'` | |
| datetime | `'created_at' => 'datetime'` | |
| timestamp | `'created_at' => 'timestamp'` | |

> **重要**: 雪花ID 在 `$casts` 中必须设为 `'string'`，不要设为 `'integer'`，否则 JSON 序列化时精度会丢失。

## Attribute Mutators

```php
/**
 * 设置生日（自动转换时间戳）
 */
public function setBirthdayAttribute($value): void
{
    if (empty($value)) {
        $this->attributes['birthday'] = null;
        return;
    }

    if (is_numeric($value)) {
        $this->attributes['birthday'] = $value;
        return;
    }

    try {
        $carbon = \Carbon\Carbon::parse($value);
        $this->attributes['birthday'] = $carbon->timestamp;
    } catch (\Exception $e) {
        $this->attributes['birthday'] = null;
    }
}

/**
 * 获取生日
 */
public function getBirthdayAttribute($value): ?string
{
    if (empty($value)) {
        return null;
    }

    try {
        return \Carbon\Carbon::createFromTimestamp($value)->toIso8601String();
    } catch (\Exception $e) {
        return null;
    }
}
```

## Auto-generation Checklist

When generating model:
- [ ] Set correct namespace based on target
- [ ] Import BaseModel (core\base or plugin variant)
- [ ] Import SoftDeletes trait
- [ ] Import related models
- [ ] Import Enum classes for status/text fields
- [ ] Set table name (plugin may have prefix)
- [ ] Set primary key
- [ ] Set fillable array
- [ ] Set hidden array (for sensitive fields)
- [ ] Set casts array
- [ ] Set appends array (for accessor attributes)
- [ ] Add accessor methods (getXxxTextAttribute)
- [ ] Add relationship methods
- [ ] Add mutator methods (setPasswordAttribute)
