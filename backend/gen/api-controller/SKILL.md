---
name: madong-gen-api-controller
description: Generate API controller for madong module前台API控制器. Supports both app (main project) and plugin targets. Creates controller extending Base class with OpenAPI attributes and standard REST endpoints for public/member access.
---

# Generate API Controller (前台 API 控制器)

Create API controller for module前台用户访问).

## File Location

**App (主项目):**
```
app/api/controller/{module}/{Model}Controller.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/api/controller/{module}/{Model}Controller.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{service_ns}` | `app\service\api` | `plugin\{Plugin}\app\service\api` |

## API Controller Features

- **继承 Base**: 继承 `app\api\controller\Base` 基类
- **无需权限验证**: 不使用 PermissionMiddleware
- **支持会员认证**: 使用 `#[AllowAnonymous]` 或 `#[MemberAuthRequired]`
- **轻量级**: 只返回必要的数据
- **雪花ID**: 主键使用雪花ID

## API Controller Template

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

namespace {ns}\api\controller\{module};

use app\api\controller\Base;
use app\api\attribute\MemberAuthRequired;
use {service_ns}\{module}\{Model}Service;
use core\tool\Json;
use madong\swagger\annotation\response\SimpleResponse;
use madong\swagger\attribute\AllowAnonymous;
use OpenApi\Attributes as OA;
use Webman\Http\Request;
use Webman\Http\Response;

/**
 * {Model}前台API控制器
 */
#[OA\Tag(name: '{Module}模块')]
final class {Model}Controller extends Base
{
    public function __construct(private {Model}Service $service)
    {
    }

    /**
     * 获取列表
     */
    #[OA\Get(
        path: '/{api_prefix}',
        summary: '获取{Model}列表',
        tags: ['{Module}模块'],
        responses: [
            new OA\Response(response: 200, description: '获取成功'),
        ]
    )]
    #[AllowAnonymous(requireToken: false, requirePermission: false)]
    #[SimpleResponse(schema: [], example: [])]
    public function index(Request $request): Response
    {
        try {
            $page    = (int) $request->input('page', 1);
            $limit   = (int) $request->input('limit', 20);
            $where   = $this->buildWhere($request);
            $order   = $request->input('order', 'id desc');

            $total = $this->service->count($where);
            $list  = $this->service->selectList($where, '*', $page, $limit, $order);

            return Json::success('ok', compact('list', 'total'));
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    /**
     * 获取详情
     */
    #[OA\Get(
        path: '/{api_prefix}/{id}',
        summary: '获取{Model}详情',
        tags: ['{Module}模块'],
        parameters: [
            new OA\Parameter(name: 'id', description: '{Model}ID', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: '获取成功'),
            new OA\Response(response: 404, description: '不存在'),
        ]
    )]
    #[AllowAnonymous(requireToken: false, requirePermission: false)]
    #[SimpleResponse(schema: [], example: [])]
    public function show(Request $request, int $id): Response
    {
        try {
            $data = $this->service->get($id);
            if (empty($data)) {
                return Json::fail('{Model}不存在', [], 404);
            }
            return Json::success('ok', $data);
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    /**
     * 创建{Model}
     */
    #[OA\Post(
        path: '/{api_prefix}',
        summary: '创建{Model}',
        tags: ['{Module}模块'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: [{required_fields}],
                properties: [
                    {form_fields}
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: '创建成功'),
            new OA\Response(response: 401, description: '未登录'),
        ]
    )]
    #[MemberAuthRequired]
    #[SimpleResponse(schema: [], example: [])]
    public function store(Request $request): Response
    {
        try {
            $data  = $request->post();
            $model = $this->service->save($data);

            $pk = $model->getPk();
            return Json::success('创建成功', [$pk => $model->getAttribute($pk)]);
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    /**
     * 更新{Model}
     */
    #[OA\Put(
        path: '/{api_prefix}/{id}',
        summary: '更新{Model}',
        tags: ['{Module}模块'],
        parameters: [
            new OA\Parameter(name: 'id', description: '{Model}ID', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: '更新成功'),
            new OA\Response(response: 401, description: '未登录'),
        ]
    )]
    #[MemberAuthRequired]
    #[SimpleResponse(schema: [], example: [])]
    public function update(Request $request, int $id): Response
    {
        try {
            $data = $request->post();
            $this->service->update($id, $data);
            return Json::success('更新成功');
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    /**
     * 删除{Model}
     */
    #[OA\Delete(
        path: '/{api_prefix}/{id}',
        summary: '删除{Model}',
        tags: ['{Module}模块'],
        parameters: [
            new OA\Parameter(name: 'id', description: '{Model}ID', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: '删除成功'),
            new OA\Response(response: 401, description: '未登录'),
        ]
    )]
    #[MemberAuthRequired]
    #[SimpleResponse(schema: [], example: [])]
    public function destroy(Request $request, int $id): Response
    {
        try {
            $this->service->delete($id);
            return Json::success('删除成功');
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    /**
     * 构建查询条件
     */
    protected function buildWhere(Request $request): array
    {
        $where = [];

        // 添加常用的查询条件
        $searchFields = [{search_fields}];

        foreach ($searchFields as $field) {
            $value = $request->input($field);
            if ($value !== null && $value !== '') {
                $where[$field] = $value;
            }
        }

        // 状态条件
        if ($request->input('status') !== null) {
            $where['status'] = (int) $request->input('status');
        }

        return $where;
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

namespace app\api\controller\question;

use app\api\controller\Base;
use app\api\attribute\MemberAuthRequired;
use app\service\api\question\QuestionService;
use core\tool\Json;
use madong\swagger\annotation\response\SimpleResponse;
use madong\swagger\attribute\AllowAnonymous;
use OpenApi\Attributes as OA;
use Webman\Http\Request;
use Webman\Http\Response;

/**
 * 问题前台API控制器
 */
#[OA\Tag(name: '问答模块')]
final class QuestionController extends Base
{
    public function __construct(private QuestionService $service)
    {
    }

    #[OA\Get(path: '/ask/question', summary: '获取问题列表', tags: ['问答模块'])]
    #[AllowAnonymous(requireToken: false, requirePermission: false)]
    public function index(Request $request): Response
    {
        try {
            $page = (int) $request->input('page', 1);
            $limit = (int) $request->input('limit', 20);
            $where = $this->buildWhere($request);

            $total = $this->service->count($where);
            $list = $this->service->selectList($where, '*', $page, $limit, 'id desc');

            return Json::success('ok', compact('list', 'total'));
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    #[OA\Get(path: '/ask/question/{id}', summary: '获取问题详情', tags: ['问答模块'])]
    #[AllowAnonymous(requireToken: false, requirePermission: false)]
    public function show(Request $request, int $id): Response
    {
        try {
            $data = $this->service->get($id);
            if (empty($data)) {
                return Json::fail('问题不存在', [], 404);
            }
            return Json::success('ok', $data);
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    #[OA\Post(path: '/ask/question', summary: '发布问题', tags: ['问答模块'])]
    #[MemberAuthRequired]
    public function store(Request $request): Response
    {
        try {
            $data = $request->post();
            $model = $this->service->save($data);
            return Json::success('发布成功', ['id' => $model->id]);
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    protected function buildWhere(Request $request): array
    {
        $where = [];
        if ($request->input('category_id')) {
            $where['category_id'] = (int) $request->input('category_id');
        }
        $where['status'] = 1;
        return $where;
    }
}
```

## Complete Example (Plugin)

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

namespace plugin\official\app\api\controller\question;

use app\api\controller\Base;
use app\api\attribute\MemberAuthRequired;
use plugin\official\app\service\api\question\QuestionService;
use core\tool\Json;
use madong\swagger\annotation\response\SimpleResponse;
use madong\swagger\attribute\AllowAnonymous;
use OpenApi\Attributes as OA;
use Webman\Http\Request;
use Webman\Http\Response;

/**
 * 问题前台API控制器
 */
#[OA\Tag(name: '问答模块')]
final class QuestionController extends Base
{
    public function __construct(private QuestionService $service)
    {
    }

    #[OA\Get(path: '/ask/question', summary: '获取问题列表', tags: ['问答模块'])]
    #[AllowAnonymous(requireToken: false, requirePermission: false)]
    public function index(Request $request): Response
    {
        try {
            $page = (int) $request->input('page', 1);
            $limit = (int) $request->input('limit', 20);
            $where = $this->buildWhere($request);

            $total = $this->service->count($where);
            $list = $this->service->selectList($where, '*', $page, $limit, 'id desc');

            return Json::success('ok', compact('list', 'total'));
        } catch (\Exception $e) {
            return Json::fail($e->getMessage());
        }
    }

    // ... 其他方法同上
}
```

## API Path Convention

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/{api_prefix}` | 公开 | 列表（分页） |
| GET | `/{api_prefix}/{id}` | 公开 | 详情 |
| POST | `/{api_prefix}` | 会员 | 创建 |
| PUT | `/{api_prefix}/{id}` | 会员 | 更新 |
| DELETE | `/{api_prefix}/{id}` | 会员 | 删除 |

## Authentication Options

### 公开接口
```php
#[AllowAnonymous(requireToken: false, requirePermission: false)]
```

### 会员专用接口
```php
#[MemberAuthRequired]
```

## Auto-generation Checklist

When generating API controller:
- [ ] Set correct namespace based on target
- [ ] Import required classes (Base, Json, MemberAuthRequired, AllowAnonymous)
- [ ] Extend Base controller
- [ ] Inject Service in constructor
- [ ] Add OpenAPI attributes for each action
- [ ] Use appropriate auth attribute (AllowAnonymous or MemberAuthRequired)
- [ ] Implement standard CRUD methods
- [ ] Use proper API path convention
- [ ] Add buildWhere() for query building
