---
name: madong-gen-controller
description: Generate CRUD controller for madong module. Supports both app (main project) and plugin targets. Creates controller extending Crud base class with OpenAPI attributes and standard REST endpoints.
---

# Step 4: Generate Admin Controller

Create CRUD controller for module.

## File Location

**App (主项目):**
```
app/adminapi/controller/{module}/{Model}Controller.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/adminapi/controller/{module}/{Model}Controller.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{service_ns}` | `app\service\admin` | `plugin\{Plugin}\app\service\admin` |

## Controller Template

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

namespace {ns}\adminapi\controller\{module};

use app\adminapi\controller\Crud;
use app\adminapi\middleware\AccessTokenMiddleware;
use app\adminapi\middleware\OperationMiddleware;
use app\adminapi\middleware\PermissionMiddleware;
use {service_ns}\{module}\{Model}Service;
use core\tool\Json;
use madong\swagger\attribute\Permission;
use madong\swagger\annotation\response\SimpleResponse;
use OpenApi\Attributes as OA;
use support\annotation\Middleware;
use support\Request;
use WebmanTech\Swagger\DTO\SchemaConstants;

#[Middleware(AccessTokenMiddleware::class, PermissionMiddleware::class, OperationMiddleware::class)]
final class {Model}Controller extends Crud
{

    public function __construct({Model}Service $service)
    {
        $this->service = $service;
    }

    #[OA\Get(
        path: '/{module}/{model}',
        summary: '列表',
        tags: ['{Module}-{Model}'],
        parameters: [
            new OA\Parameter(name: "page", description: "页码", in: "query", schema: new OA\Schema(type: "integer")),
            new OA\Parameter(name: "limit", description: "每页数量", in: "query", schema: new OA\Schema(type: "integer")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "获取成功"),
                    new OA\Property(property: "data", properties: [
                        new OA\Property(property: "total", type: "integer", example: 10),
                        new OA\Property(property: "list", type: "array", items: new OA\Items()),
                    ], type: "object"),
                ])
            ),
        ]
    )]
    #[Permission("{module}:{model}:list")]
    public function index(Request $request): \support\Response
    {
        try {
            [$where, $format, $limit, $field, $order, $page] = $this->selectInput($request);
            $methods         = [
                'select'     => 'formatSelect',
                'tree'       => 'formatTree',
                'table_tree' => 'formatTableTree',
                'normal'     => 'formatNormal',
            ];
            $format_function = $methods[$format] ?? 'formatNormal';
            $total           = $this->service->getCount($where);
            $list            = $this->service->selectList($where, $field, $page, $limit, $order, [], false);
            return call_user_func([$this, $format_function], $list, $total);
        } catch (\Throwable $e) {
            return Json::fail($e->getMessage());
        }
    }

    #[OA\Get(
        path: '/{module}/{model}/{id}',
        summary: '详情',
        tags: ['{Module}-{Model}'],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "获取成功"),
                ])
            ),
        ],
        x: [
            SchemaConstants::X_PROPERTY_IN => 'id',
        ]
    )]
    #[Permission("{module}:{model}:read")]
    public function show(Request $request): \support\Response
    {
        return parent::show($request);
    }

    #[OA\Post(
        path: '/{module}/{model}',
        summary: '创建',
        tags: ['{Module}-{Model}'],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "创建成功"),
                ])
            ),
        ],
    )]
    #[Permission("{module}:{model}:create")]
    #[SimpleResponse(example: '{"code":0,"msg":"created","id":1}')]
    public function store(Request $request): \support\Response
    {
        return parent::store($request);
    }

    #[OA\Put(
        path: '/{module}/{model}/{id}',
        summary: '更新',
        tags: ['{Module}-{Model}'],
        parameters: [
            new OA\Parameter(name: "id", description: "ID", in: "path", required: true, schema: new OA\Schema(type: "integer")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "更新成功"),
                ])
            ),
        ]
    )]
    #[Permission("{module}:{model}:update")]
    public function update(Request $request): \support\Response
    {
        return parent::update($request);
    }

    #[OA\Delete(
        path: '/{module}/{model}/{id}',
        summary: '删除',
        tags: ['{Module}-{Model}'],
        parameters: [
            new OA\Parameter(name: "id", description: "ID", in: "path", required: true, schema: new OA\Schema(type: "integer")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "删除成功"),
                ])
            ),
        ],
        x: [
            SchemaConstants::X_PROPERTY_IN => 'id',
        ]
    )]
    #[Permission("{module}:{model}:delete")]
    public function destroy(Request $request): \support\Response
    {
        return parent::destroy($request);
    }

    #[OA\Delete(
        path: '/{module}/{model}',
        summary: '批量删除',
        tags: ['{Module}-{Model}'],
        x: [SchemaConstants::X_SCHEMA_REQUEST => \app\schema\request\BatchDeleteRequest::class],
    )]
    #[Permission("{module}:{model}:delete")]
    public function batchDelete(Request $request): \support\Response
    {
        return parent::destroy($request);
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

namespace app\adminapi\controller\member;

use app\adminapi\controller\Crud;
use app\adminapi\middleware\AccessTokenMiddleware;
use app\adminapi\middleware\OperationMiddleware;
use app\adminapi\middleware\PermissionMiddleware;
use app\service\admin\member\MemberService;
use core\tool\Json;
use madong\swagger\attribute\Permission;
use madong\swagger\annotation\response\SimpleResponse;
use OpenApi\Attributes as OA;
use support\annotation\Middleware;
use support\Request;
use WebmanTech\Swagger\DTO\SchemaConstants;

#[Middleware(AccessTokenMiddleware::class, PermissionMiddleware::class, OperationMiddleware::class)]
final class MemberController extends Crud
{

    public function __construct(MemberService $service)
    {
        $this->service = $service;
    }

    #[OA\Get(
        path: '/member/user',
        summary: '会员用户列表',
        tags: ['会员用户'],
        parameters: [
            new OA\Parameter(name: "username", description: "用户名", in: "query", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "nickname", description: "昵称", in: "query", schema: new OA\Schema(type: "string")),
            new OA\Parameter(name: "page", description: "页码", in: "query", schema: new OA\Schema(type: "integer")),
            new OA\Parameter(name: "limit", description: "每页数量", in: "query", schema: new OA\Schema(type: "integer")),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "成功",
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: "code", type: "integer", example: 0),
                    new OA\Property(property: "msg", type: "string", example: "获取成功"),
                ])
            ),
        ]
    )]
    #[Permission("member:user:list")]
    public function index(Request $request): \support\Response
    {
        try {
            [$where, $format, $limit, $field, $order, $page] = $this->selectInput($request);
            $methods         = [
                'select'     => 'formatSelect',
                'tree'       => 'formatTree',
                'table_tree' => 'formatTableTree',
                'normal'     => 'formatNormal',
            ];
            $format_function = $methods[$format] ?? 'formatNormal';
            $total           = $this->service->getCount($where);
            $list            = $this->service->selectList($where, $field, $page, $limit, $order, ['level', 'tags'], false);
            return call_user_func([$this, $format_function], $list, $total);
        } catch (\Throwable $e) {
            return Json::fail($e->getMessage());
        }
    }

    #[OA\Get(
        path: '/member/user/{id}',
        summary: '会员用户详情',
        tags: ['会员用户'],
        responses: [
            new OA\Response(response: 200, description: "成功"),
        ],
        x: [SchemaConstants::X_PROPERTY_IN => 'id']
    )]
    #[Permission("member:user:read")]
    public function show(Request $request): \support\Response
    {
        return parent::show($request);
    }

    #[OA\Post(path: '/member/user', summary: '创建', tags: ['会员用户'])]
    #[Permission("member:user:create")]
    #[SimpleResponse(example: '{"code":0,"msg":"created","id":1}')]
    public function store(Request $request): \support\Response
    {
        return parent::store($request);
    }

    #[OA\Put(path: '/member/user/{id}', summary: '更新', tags: ['会员用户'])]
    #[Permission("member:user:update")]
    public function update(Request $request): \support\Response
    {
        return parent::update($request);
    }

    #[OA\Delete(path: '/member/user/{id}', summary: '删除', tags: ['会员用户'])]
    #[Permission("member:user:delete")]
    public function destroy(Request $request): \support\Response
    {
        return parent::destroy($request);
    }
}
```

## API Path Convention

| Method | Path | Description |
|--------|------|-------------|
| GET | `/{module}/{model}` | List with pagination |
| GET | `/{module}/{model}/{id}` | Get single record |
| POST | `/{module}/{model}` | Create new record |
| PUT | `/{module}/{model}/{id}` | Update record |
| DELETE | `/{module}/{model}/{id}` | Delete single record |
| DELETE | `/{module}/{model}` | Batch delete records |

## Permission Codes

| Action | Permission | Description |
|--------|------------|-------------|
| List | `{module}:{model}:list` | View list |
| View | `{module}:{model}:read` | View detail |
| Create | `{module}:{model}:create` | Create new |
| Update | `{module}:{model}:update` | Update existing |
| Delete | `{module}:{model}:delete` | Delete records |

## Middleware Stack

The controller uses three middleware:

1. **AccessTokenMiddleware**: Authentication
2. **PermissionMiddleware**: Permission check
3. **OperationMiddleware**: Operation logging

## Inherited Crud Methods

The Crud base controller provides:

| Method | Description |
|--------|-------------|
| `index()` | List with pagination |
| `show()` | Get single record |
| `store()` | Create record |
| `update()` | Update record |
| `destroy()` | Delete record (single and batch) |
| `selectInput()` | Parse request parameters |
| `formatSelect()` | Format for select dropdown |
| `formatTree()` | Format for tree structure |
| `formatTableTree()` | Format for table tree |
| `formatNormal()` | Format for normal list |

## Auto-generation Checklist

When generating controller:
- [ ] Set correct namespace based on target
- [ ] Import required classes (Controller, Service, Middleware, Json, etc.)
- [ ] Add Middleware attribute with three middlewares
- [ ] Extend Crud base controller
- [ ] Inject Service in constructor
- [ ] Add OpenAPI attributes for each action
- [ ] Add Permission attribute for each action
- [ ] Use proper API path convention
