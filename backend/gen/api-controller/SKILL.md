---
name: madong-gen-api-controller
description: Generate API controller for madong module (前台 API 控制器). Supports both app (main project) and plugin targets. Creates plain controller class with OpenAPI attributes and REST endpoints.
---

# Generate API Controller (前台 API 控制器)

Create API controller for module (前台用户访问).

> **注意**: 基于 portal 插件实际实现，API 控制器为**纯类**（不继承基类），使用 `support\Request/Response`，通过 `CurrentMember` 获取当前会员信息。

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
| `{service_ns}` | `app\api\service` | `plugin\{Plugin}\app\api\service` |

## API Controller Features

- **纯类实现**: 不继承基类，直接实现控制器
- **注入 Service 和 CurrentMember**: 通过构造函数注入 `{Model}Service` 和 `CurrentMember`
- **JSON 响应**: 使用 `core\foundation\tool\Json`
- **Swagger 注解**: 使用 `PageResponse`/`SimpleResponse` 注解
- **雪花ID**: 使用 `string` 类型接收雪花ID

## API Controller Template

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

namespace {ns}\api\controller\{module};

use app\api\CurrentMember;
use core\foundation\tool\Json;
use madong\swagger\annotation\response\PageResponse;
use madong\swagger\annotation\response\SimpleResponse;
use {service_ns}\{module}\{Model}Service;
use support\Request;
use support\Response;
use OpenApi\Attributes as OA;

/**
 * {Model}API控制器
 */
class {Model}Controller
{
    protected {Model}Service $service;
    private readonly CurrentMember $currentMember;

    public function __construct({Model}Service $service, CurrentMember $currentMember)
    {
        $this->service = $service;
        $this->currentMember = $currentMember;
    }

    /**
     * 获取列表
     */
    #[OA\Get(
        path: '/{api_prefix}',
        summary: '获取{Model}列表',
        tags: ['{Module}'],
        parameters: [
            new OA\Parameter(name: 'page', description: '页码', in: 'query', schema: new OA\Schema(type: 'integer', default: 1)),
            new OA\Parameter(name: 'limit', description: '每页数量', in: 'query', schema: new OA\Schema(type: 'integer', default: 20)),
        ],
    )]
    #[PageResponse(schema: [], example: [])]
    public function index(Request $request): Response
    {
        $params = $request->all();
        $result = $this->service->getList($params);
        return Json::success('获取成功', $result);
    }

    /**
     * 获取详情
     */
    #[OA\Get(
        path: '/{api_prefix}/{id}',
        summary: '获取{Model}详情',
        tags: ['{Module}'],
        parameters: [
            new OA\Parameter(name: 'id', description: '{Model}ID', in: 'path', required: true, schema: new OA\Schema(type: 'string')),
        ],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function show(string $id): Response
    {
        $result = $this->service->detail($id);
        return Json::success('获取成功', $result);
    }

    /**
     * 创建{Model}
     */
    #[OA\Post(
        path: '/{api_prefix}',
        summary: '创建{Model}',
        tags: ['{Module}'],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function store(Request $request): Response
    {
        $data = $request->all();
        $data['member_id'] = $this->currentMember->id();
        $result = $this->service->create($data);
        return Json::success('创建成功', $result);
    }

    /**
     * 更新{Model}
     */
    #[OA\Put(
        path: '/{api_prefix}/{id}',
        summary: '更新{Model}',
        tags: ['{Module}'],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function update(Request $request, string $id): Response
    {
        $data = $request->all();
        $result = $this->service->update($id, $data);
        return Json::success('更新成功', $result);
    }

    /**
     * 删除{Model}
     */
    #[OA\Delete(
        path: '/{api_prefix}/{id}',
        summary: '删除{Model}',
        tags: ['{Module}'],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function destroy(string $id): Response
    {
        $this->service->delete($id);
        return Json::success('删除成功');
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

namespace plugin\portal\app\api\controller\question;

use app\api\CurrentMember;
use core\foundation\tool\Json;
use madong\swagger\annotation\response\PageResponse;
use madong\swagger\annotation\response\SimpleResponse;
use plugin\portal\app\api\service\question\QuestionService;
use support\Request;
use support\Response;
use OpenApi\Attributes as OA;

/**
 * 问题API控制器
 */
class QuestionController
{
    protected QuestionService $service;
    private readonly CurrentMember $currentMember;

    public function __construct(QuestionService $service, CurrentMember $currentMember)
    {
        $this->service = $service;
        $this->currentMember = $currentMember;
    }

    #[OA\Get(
        path: '/ask/questions',
        summary: '获取问题列表',
        tags: ['问答社区'],
        parameters: [
            new OA\Parameter(name: 'page', description: '页码', in: 'query', schema: new OA\Schema(type: 'integer', default: 1)),
            new OA\Parameter(name: 'limit', description: '每页数量', in: 'query', schema: new OA\Schema(type: 'integer', default: 20)),
            new OA\Parameter(name: 'category_id', description: '分类ID', in: 'query', schema: new OA\Schema(type: 'string')),
            new OA\Parameter(name: 'keywords', description: '搜索关键词', in: 'query', schema: new OA\Schema(type: 'string')),
        ],
    )]
    #[PageResponse(schema: [], example: [])]
    public function index(Request $request): Response
    {
        $params = $request->all();
        $result = $this->service->getList($params);
        return Json::success('获取成功', $result);
    }

    #[OA\Get(
        path: '/ask/questions/{id}',
        summary: '获取问题详情',
        tags: ['问答社区'],
        parameters: [
            new OA\Parameter(name: 'id', description: '问题ID', in: 'path', required: true, schema: new OA\Schema(type: 'string')),
        ],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function show(string $id): Response
    {
        $result = $this->service->show($id);
        return Json::success('获取成功', $result);
    }

    #[OA\Post(
        path: '/ask/questions',
        summary: '创建问题',
        tags: ['问答社区'],
    )]
    #[SimpleResponse(schema: [], example: [])]
    public function store(Request $request): Response
    {
        $data = $request->all();
        $data['member_id'] = $this->currentMember->id();
        $result = $this->service->create($data);
        return Json::success('创建成功', $result);
    }

    // ... update, destroy 类似
}
```

## API Path Convention

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/{api_prefix}` | 公开 | 列表（分页） |
| GET | `/{api_prefix}/{id}` | 公开 | 详情（雪花ID string） |
| POST | `/{api_prefix}` | 会员 | 创建（设置 member_id） |
| PUT | `/{api_prefix}/{id}` | 会员 | 更新 |
| DELETE | `/{api_prefix}/{id}` | 会员 | 删除 |

## Auto-generation Checklist

When generating API controller:
- [ ] Set correct namespace `{ns}\api\controller\{module}`
- [ ] Import `CurrentMember`, `core\foundation\tool\Json`, `support\Request`, `support\Response`
- [ ] Import `PageResponse`/`SimpleResponse` from `madong\swagger\annotation\response`
- [ ] Plain class (不继承基类)
- [ ] Inject `{Model}Service` and `CurrentMember` in constructor
- [ ] Add OpenAPI attributes for each action
- [ ] Use `$request->all()` for input data
- [ ] Use `string $id` for snowflake ID
- [ ] Implement custom API endpoints as needed
