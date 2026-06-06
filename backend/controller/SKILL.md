---
name: madong-backend-controller
description: AdminAPI/Platform/API 控制器规范，继承 Crud 或 Base 基类
globs:
  - "app/**/controller/**/*.php"
---

## 文件位置

| 端 | 路径 | 基类 |
|----|------|------|
| AdminAPI | `app/adminapi/controller/{module}/{Name}Controller.php` | `Crud > Base > BaseController` |
| Platform | `app/platform/controller/{module}/{Name}Controller.php` | `Base(extends Crud) > BaseController` |
| API | `app/api/controller/{module}/{Name}Controller.php` | `Base > BaseController` |
| Install | `app/install/controller/{Name}Controller.php` | `Base > BaseController` |
| Plugin | `addon/{plugin}/controller/{Name}Controller.php` | `Crud > Base > BaseController` |

## 基类说明

### BaseController (`core\foundation\base\BaseController`)

```php
abstract class BaseController
{
    protected BaseService|null $service = null;
    protected BaseValidate|null $validate = null;
    abstract protected function initialize(): void;
    public function __construct() { $this->initialize(); }
}
```

### Crud (`app\adminapi\controller\Crud`)

| 方法 | 路由 | 说明 |
|------|------|------|
| `index()` | GET /{module} | 列表查询（支持 tree/table_tree/normal/select） |
| `store()` | POST /{module} | 插入数据 |
| `show($id)` | GET /{module}/{id} | 查询详情 |
| `update($id)` | PUT /{module}/{id} | 更新数据 |
| `destroy($id)` | DELETE /{module}/{id} | 删除（支持批量） |
| `changeStatus()` | PUT /{module}/changeStatus | 更新状态 |
| `export()` | POST /{module}/export | Excel导出 |
| `recovery($id)` | PUT /{module}/recovery | 数据恢复 |

## 代码模板

### AdminAPI 控制器

```php
<?php
declare(strict_types=1);

namespace app\adminapi\controller\{module};

use app\adminapi\controller\Crud;
use app\adminapi\middleware\AccessTokenMiddleware;
use app\adminapi\middleware\OperationMiddleware;
use app\adminapi\middleware\PermissionMiddleware;
use app\adminapi\validate\{module}\{Model}Validate;
use app\service\admin\{module}\{Model}Service;
use core\foundation\tool\Json;
use madong\swagger\attribute\Permission;
use OpenApi\Attributes as OA;
use support\annotation\Middleware;

#[Middleware(AccessTokenMiddleware::class, PermissionMiddleware::class, OperationMiddleware::class)]
#[OA\Tag(name: '{module_name}管理')]
final class {Model}Controller extends Crud
{
    public function __construct({Model}Service $service, {Model}Validate $validate)
    {
        $this->service = $service;
        $this->validate = $validate;
    }

    #[OA\Get(path: '/adminapi/{module_route}', summary: '{model_name}列表')]
    #[Permission('{module}:{model}:list')]
    public function index(Request $request): \Json
    {
        return parent::index($request);
    }

    #[OA\Post(path: '/adminapi/{module_route}', summary: '创建{model_name}')]
    #[Permission('{module}:{model}:create')]
    public function store(Request $request): \Json
    {
        return parent::store($request);
    }

    // ... show / update / destroy / changeStatus
}
```

### Platform 控制器

```php
<?php
declare(strict_types=1);

namespace app\platform\controller\{module};

use app\platform\controller\Base;
use app\platform\validate\{module}\{Model}Validate;
use app\service\platform\{module}\{Model}Service;
use core\foundation\tool\Json;
use madong\swagger\attribute\Permission;
use OpenApi\Attributes as OA;
use support\annotation\Middleware;

#[Middleware(AccessTokenMiddleware::class, PermissionMiddleware::class, OperationMiddleware::class)]
final class {Model}Controller extends Base
{
    // 同 AdminAPI 模式
}
```

## 目标变量表

| 变量 | App 模式 | Plugin 模式 |
|------|---------|------------|
| `{module}` | system/member/content/ops | 插件名 |
| `{module_route}` | system/member/content/ops | 插件route |
| `{module_name}` | 系统管理/会员管理 | 插件名称 |
| `{model_name}` | 菜单/会员 | 插件模型名称 |
| `{Model}` | Menu/Member | PluginModel |
| `{module}:{model}` | system:menu | plugin:model |

## 关键约定

- AdminAPI 控制器必须使用 `#[Middleware]` 声明三个中间件：AccessToken + Permission + Operation
- 权限码格式：`{module}:{model}:{action}`（list/create/update/delete/export）
- 使用 `#[OA\Tag]` 在类上为所有 API 分组
- 每个公开方法都需要 `#[OA\Get/Post/Put/Delete]` 注解（用于路由注册+API文档）
- 返回统一使用 `Json::success()` / `Json::fail()`，不允许直接 `return json()`
- 不要在控制器中直接操作 DAO/Model，必须通过 Service 层
- Crud 基类已自动校验 + 过滤输入，子类只需要注入 service 和 validate
- Platform 控制器使用 `app\platform\controller\Base`，它同样继承自 Crud

## 检查清单

- [ ] 类上是否声明了 `#[Middleware]` 三个中间件
- [ ] 每个方法是否有 `#[OA\*]` 注解
- [ ] 权限码是否按 `{module}:{model}:{action}` 格式
- [ ] 是否使用 `Json::success()`/`Json::fail()` 返回
- [ ] 命名空间是否正确（adminapi/platform/api）
- [ ] 是否通过 Service 操作数据，未直接调用 DAO
- [ ] 是否注册了对应的路由（Swagger 注解自动注册）
