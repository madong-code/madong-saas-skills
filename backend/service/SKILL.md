---
name: madong-backend-service
description: 服务层规范，继承 BaseService，通过 DAO 操作数据
globs:
  - "app/**/service/**/*.php"
---

## 文件位置

| 端 | 路径 | 基类 |
|----|------|------|
| Admin | `app/service/admin/{module}/{Model}Service.php` | `core\foundation\base\BaseService` |
| API | `app/service/api/{module}/{Model}Service.php` | `core\foundation\base\BaseService` |
| Platform | `app/service/platform/{module}/{Model}Service.php` | `core\foundation\base\BaseService` |
| Core | `app/service/core/{module}/{Model}Service.php` | `core\foundation\base\BaseService` |

## 基类说明

### BaseService (`core\foundation\base\BaseService`)

```php
abstract class BaseService
{
    public function __call(string $name, array $arguments): mixed
    {
        return $this->dao->{$name}(...$arguments);
    }
}
```

`__call` 魔术方法自动代理到 DAO 层，因此普通 CRUD 操作（selectList/save/update/delete/get）无需在 Service 中声明方法，直接调用 `$service->selectList(...)` 即可。

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\service\admin\{module};

use app\dao\{module}\{Model}Dao;
use core\foundation\base\BaseService;
use core\foundation\trait\ServiceTrait;
use support\Container;

class {Model}Service extends BaseService
{
    // 可选：使用 ServiceTrait 获得额外方法
    // use ServiceTrait;

    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }

    /**
     * 带事务的业务方法
     */
    public function complexBusiness(array $data): bool
    {
        return $this->dao->getModel()->getConnection()->transaction(function () use ($data) {
            // 业务逻辑...
            $this->dao->save($data);
            // 触发事件
            Container::get(EventDispatcher::class)->dispatch(new {Model}CreatedEvent($data));
            return true;
        });
    }
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system/member/content/ops 等 |
| `{Model}` | Menu/Member/Article 等 |
| `{Model}Dao` | MenuDao/MemberDao 等 |

## 数据流

```
Controller → Service → DAO → Model → DB
                 ↓
            __call代理
```

## 关键约定

- Service 构造注入 DAO，不允许注入 Model
- 普通 CRUD 无需写方法，`__call` 自动代理到 DAO
- 业务逻辑写在 Service 层，不要在 Controller 中实现
- 事务使用 `$this->dao->getModel()->getConnection()->transaction()`
- Service 负责事件分发（dispatch），Controller 不直接分发事件
- 可以使用 `core\foundation\trait\ServiceTrait` 获得常用方法
- 复杂查询逻辑封装在 Service，简单查询直接通过 `__call` 代理

## 检查清单

- [ ] 是否通过 `__construct({Model}Dao $dao)` 注入 DAO
- [ ] 简单的 CRUD 是否通过 `__call` 代理（无需手写方法）
- [ ] 复杂业务是否使用了事务包裹
- [ ] 事件是否在 Service 层触发，而非 Controller
- [ ] 命名空间是否正确匹配所属端（admin/api/platform/core）
