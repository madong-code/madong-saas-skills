---
name: madong-backend-event
description: 事件规范，继承 BaseEvent
globs:
  - "app/**/event/**/*.php"
---

## 文件位置

```
app/{module}/event/{Model}{Action}Event.php
```

事件分散在各端目录下：

| 端 | 路径 |
|----|------|
| AdminAPI 事件 | `app/adminapi/event/{Model}{Action}Event.php` |
| 通用事件 | `app/event/{Model}{Action}Event.php` |

## 基类说明

### BaseEvent (`core\foundation\base\BaseEvent`)

```php
abstract class BaseEvent
{
    // 事件数据通过公开属性传递
}
```

### 事件分发

```php
use Webman\Event\Event;

// 触发事件
Event::emit('{app}.{module}.{action}', $eventData);

// 或通过容器分发
Container::get(EventDispatcher::class)->dispatch($event);
```

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\{app}\event\{module};

use core\foundation\base\BaseEvent;

class {Model}{Action}Event extends BaseEvent
{
    // 公开属性，监听器可直接访问
    public array $data;
    public int $modelId;

    public function __construct(array $data, int $modelId)
    {
        $this->data = $data;
        $this->modelId = $modelId;
    }
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{app}` | adminapi/platform/api 等 |
| `{module}` | system/member/content 等 |
| `{Model}` | Menu/Member 等 |
| `{Action}` | Created/Updated/Deleted/Registered 等 |

## 关键约定

- 事件数据通过公开属性传递（`public` 属性），不通过 getter 方法
- 事件名格式：`{app}.{module}.{action}`（如 `adminapi.member.register`）
- 事件类不包含业务逻辑，只作为数据传输对象
- 事件在 Service 层触发，不在 Controller 层触发
- 同步事件直接在事件触发处等待执行完成

## 检查清单

- [ ] 事件属性是否都是 `public`
- [ ] 事件名是否符合 `{app}.{module}.{action}` 格式
- [ ] 构造函数是否接收并赋值所有必要数据
- [ ] 事件是否在 Service 层触发（而非 Controller）
- [ ] 命名空间是否正确
