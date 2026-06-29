---
name: madong-gen-validate
description: Generate validation class for madong module. Supports both app (main project) and plugin targets. Creates validate extending BaseValidate with Laravel validation rules and scene definitions.
---

# Generate Validate

Create validation class for module.

## File Location

**App (主项目):**
```
app/adminapi/validate/{module}/{Model}Validate.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/adminapi/validate/{module}/{Model}Validate.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{model_ns}` | `app\model` | `plugin\{Plugin}\app\model` |
| `{validate_ns}` | `app\adminapi\validate` | `plugin\{Plugin}\app\adminapi\validate` |

> **注意**: 基于 portal 实际实现，validate 目录可能为空（验证逻辑直接在 Controller 中完成）。Generate 时可以跳过 validate 生成，除非需要独立的验证器。

## Validate Template

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

namespace {ns}\adminapi\validate\{module};

use {model_ns}\{module}\{Model};
use core\base\BaseValidate;
use Illuminate\Validation\Rule;

/**
 * {Model}验证器
 *
 * Class {Model}Validate
 */
class {Model}Validate extends BaseValidate
{
    /**
     * 验证规则
     */
    public function rules(): array
    {
        $id = request()->route->param('id');

        return [
            {rules}
        ];
    }

    /**
     * 验证消息
     */
    protected array $message = [
        {messages}
    ];

    /**
     * 验证场景
     */
    protected array $scene = [
        'store'  => [
            {store_fields}
        ],
        'update' => [
            {update_fields}
        ],
    ];

    /**
     * 创建验证场景
     */
    public function sceneStore(): {Model}Validate
    {
        return $this->only($this->scene['store']);
    }

    /**
     * 更新验证场景
     */
    public function sceneUpdate(): {Model}Validate
    {
        return $this->only($this->scene['update']);
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

namespace app\adminapi\validate\member;

use app\model\member\Member;
use core\base\BaseValidate;
use Illuminate\Validation\Rule;

/**
 * 会员验证器
 *
 * Class MemberValidate
 */
class MemberValidate extends BaseValidate
{
    /**
     * 验证规则
     */
    public function rules(): array
    {
        $id = request()->route->param('id');

        return [
            'username' => ['required', 'max:50', Rule::unique(Member::class, 'username')->ignore($id, 'id')],
            'email'    => ['email', 'max:100'],
            'phone'    => ['max:20'],
            'password' => 'required|min:6|max:60',
            'nickname' => 'max:50',
            'level_id' => 'integer|min:1',
            'points'   => 'integer|min:0',
            'balance'  => 'number|min:0',
            'gender'   => 'in:0,1,2',
            'birthday' => 'date',
            'enabled'   => 'in:0,1',
        ];
    }

    /**
     * 验证消息
     */
    protected array $message = [
        'username.required' => '用户名不能为空',
        'username.max'      => '用户名不能超过50个字符',
        'username.unique'   => '用户名已存在',
        'email.email'       => '邮箱格式不正确',
        'email.max'         => '邮箱不能超过100个字符',
        'phone.max'         => '手机号格式不正确',
        'password.required' => '密码不能为空',
        'password.min'      => '密码不能少于6个字符',
        'password.max'      => '密码不能超过60个字符',
        'nickname.max'      => '昵称不能超过50个字符',
        'level_id.integer'  => '等级ID必须为整数',
        'points.integer'    => '积分必须为整数',
        'balance.number'    => '余额必须为数字',
        'gender.in'         => '性别值不正确',
        'birthday.date'     => '生日格式不正确',
        'enabled.in'        => '状态值不正确',
    ];

    /**
     * 验证场景
     */
    protected array $scene = [
        'store'  => [
            'username',
            'email',
            'phone',
            'password',
            'nickname',
            'level_id',
            'points',
            'balance',
            'gender',
            'birthday',
            'enabled',
        ],
        'update' => [
            'username',
            'email',
            'phone',
            'nickname',
            'level_id',
            'points',
            'balance',
            'gender',
            'birthday',
            'enabled',
        ],
    ];

    /**
     * 创建验证场景
     */
    public function sceneStore(): MemberValidate
    {
        return $this->only($this->scene['store']);
    }

    /**
     * 更新验证场景
     */
    public function sceneUpdate(): MemberValidate
    {
        return $this->only($this->scene['update']);
    }
}
```

## Validation Rules Reference

| Rule | Example | Description |
|------|---------|-------------|
| required | `'field' => 'required'` | 必填 |
| nullable | `'field' => 'nullable'` | 可为空 |
| integer | `'field' => 'integer'` | 整数 |
| numeric | `'field' => 'numeric'` | 数字 |
| string | `'field' => 'string'` | 字符串 |
| email | `'field' => 'email'` | 邮箱格式 |
| max | `'field' => 'max:50'` | 最大长度 |
| min | `'field' => 'min:6'` | 最小长度 |
| in | `'field' => 'in:0,1,2'` | 枚举值 |
| unique | `'field' => Rule::unique(Model::class)` | 唯一性 |
| date | `'field' => 'date'` | 日期格式 |
| array | `'field' => 'array'` | 数组 |
| alpha | `'field' => 'alpha'` | 仅字母 |
| alpha_num | `'field' => 'alpha_num'` | 字母数字 |

## Custom Scene Example

```php
/**
 * 重置密码验证
 */
public function sceneResetPassword(): MemberValidate
{
    return $this->only([])
        ->append('id', 'require|integer|min:1')
        ->append('password', 'require|min:6|max:20');
}

/**
 * 状态更新验证
 */
public function sceneStatus(): MemberValidate
{
    return $this->only([])
        ->append('id', 'require|integer|min:1')
        ->append('status', 'require|in:0,1');
}

/**
 * 批量删除验证
 */
public function sceneBatchDelete(): MemberValidate
{
    return $this->only([])
        ->append('ids', 'require|array|min:1');
}
```

## Auto-generation Checklist

When generating validate:
- [ ] Set correct namespace based on target
- [ ] Import BaseValidate
- [ ] Import Model class
- [ ] Define rules() method with Laravel validation
- [ ] Use Rule::unique() for unique fields
- [ ] Define $message for custom error messages
- [ ] Define $scene for validation scenes
- [ ] Implement sceneStore() method
- [ ] Implement sceneUpdate() method
