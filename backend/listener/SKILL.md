---
name: madong-backend-listener
description: 监听器规范，继承 BaseListener，注册到 config/event.php
globs:
  - "app/**/listener/**/*.php"
---

## 文件位置

```
app/{module}/listener/{Model}{Action}Listener.php
```

## 基类说明

### BaseListener (`core\foundation\base\BaseListener`)

```php
abstract class BaseListener
{
    abstract public function handle(object $event): void;
}
```

### 监听器注册 (`config/event.php`)

```php
return [
    'adminapi.member.register' => [
        \app\adminapi\listener\member\MemberRegisterListener::class,
    ],
];
```

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\{app}\listener\{module};

use app\dao\{module}\{Model}Dao;
use core\foundation\base\BaseListener;
use core\foundation\tool\Json;
use support\Container;

class {Model}{Action}Listener extends BaseListener
{
    public function handle(object $event): void
    {
        // 通过容器获取 DAO
        $dao = Container::make({Model}Dao::class);

        // 访问事件属性
        $data = $event->data;
        $modelId = $event->modelId;

        // 业务处理...
        $dao->update($modelId, ['processed' => 1]);
    }
}
```

## 注册配置 (`config/event.php`)

```php
return [
    // 事件名 => [监听器列表]
    'adminapi.{module}.{action}' => [
        \app\{app}\listener\{module}\{Model}{Action}Listener::class,
    ],
];
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{app}` | adminapi/platform/api 等 |
| `{module}` | system/member/content 等 |
| `{Model}` | Menu/Member 等 |
| `{Action}` | Created/Updated/Deleted/Registered 等 |

## 关键约定

- `handle()` 方法接收事件对象作为唯一参数
- 通过 `Container::make()` 获取 DAO/Service 实例（支持依赖注入）
- 监听器不能返回数据，只消费事件
- 一个事件可以有多个监听器，按 `config/event.php` 中注册顺序执行
- 监听器内不要抛出异常，异常应自行捕获处理
- 监听器注册到 `config/event.php`，非 `config/listener.php`

## 检查清单

- [ ] 是否继承 `BaseListener`
- [ ] `handle()` 方法签名是否正确：`handle(object $event): void`
- [ ] 是否通过 `Container::make()` 获取依赖，而非 `new`
- [ ] 监听器是否已注册到 `config/event.php`
- [ ] 事件名是否与事件定义一致
- [ ] 命名空间是否正确
