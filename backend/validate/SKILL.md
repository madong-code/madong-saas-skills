---
name: madong-backend-validate
description: 验证器规范，继承 BaseValidate
globs:
  - "app/**/validate/**/*.php"
---

## 文件位置

| 端 | 路径 |
|----|------|
| AdminAPI | `app/adminapi/validate/{module}/{Model}Validate.php` |
| Platform | `app/platform/validate/{module}/{Model}Validate.php` |
| API | `app/api/validate/{module}/{Model}Validate.php` |

## 基类说明

### BaseValidate (`core\foundation\base\BaseValidate`)

- `rules()` - 定义验证规则数组
- `messages()` - 自定义错误消息
- `scene()` - 场景定义（store/update 等）
- `check($data)` - 执行验证
- `getError()` - 获取错误消息

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\adminapi\validate\{module};

use core\foundation\base\BaseValidate;

class {Model}Validate extends BaseValidate
{
    // 验证规则
    protected array $rules = [
        'name'   => 'required|max:50',
        'status' => 'numeric|in:0,1',
        'sort'   => 'numeric',
        'pid'    => 'required|numeric',
    ];

    // 错误信息
    protected array $messages = [
        'name.required'   => '{field_name}必须填写',
        'name.max'        => '{field_name}不能超过50个字符',
        'status.numeric'  => '{field_name}格式错误',
        'pid.required'    => '{field_name}必须选择',
    ];

    // 场景定义
    protected array $scene = [
        'store'  => ['name', 'status', 'sort', 'pid'],
        'update' => ['name', 'status', 'sort'],
    ];

    // 自定义验证方法（格式：check{Field}{Rule}）
    protected function checkPathUnique(string $value, string $rule, array $data): bool
    {
        // ...
        return true;
    }
}
```

## 场景说明

| 场景 | 说明 |
|------|------|
| `store` | 新增时验证的字段 |
| `update` | 更新时验证的字段（通常比 store 少一些必填字段） |

## 关键约定

- 验证器属性命名遵循：`$rules` / `$messages` / `$scene`
- 自定义验证方法命名格式 `check{Field}{Rule}`，如 `checkNameUnique`
- `$scene` 定义哪些字段在哪个场景中被验证
- 错误消息使用中文，格式为 `{字段名}必须填写/格式错误/不能超过X个字符`
- 控制器在 `initialize()` 中注入验证器，Crud 基类自动调用 `$this->validate->scene('store')->check($data)`
- 验证器只负责格式/规则验证，不处理业务逻辑
- 支持 Laravel 原生验证规则：`required`, `max`, `min`, `numeric`, `in`, `unique`, `confirmed` 等

## 检查清单

- [ ] `$rules` 是否定义了所有需要验证的字段
- [ ] `$messages` 是否都有对应的中文错误提示
- [ ] `$scene` 是否定义了 store 和 update 两个场景
- [ ] 自定义验证方法名是否符合 `checkFieldRule` 格式
- [ ] 命名空间是否正确
