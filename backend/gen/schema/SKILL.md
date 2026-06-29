---
name: madong-gen-schema
description: Generate Schema classes for madong module. Supports both app (main project) and plugin targets. Creates request/response DTOs with OpenAPI attributes for API documentation.
---

# Generate Schema

Create Schema classes for API request/response DTOs.

## File Location

**App (主项目):**
```
app/schema/request/{module}/{Model}Request.php
app/schema/response/{module}/{Model}Response.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/schema/request/{module}/{Model}Request.php
plugin/{plugin}/app/schema/response/{module}/{Model}Response.php
```

> **注意**: 基于 portal 实际实现，plugin schema 目录可以为空（Swagger 直接从 controller/service 注解扫描）。Generate 时可以跳过 plugin schema 生成，除非需要显式 Request/Response DTO。

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |

## Request Schema Template

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

namespace {ns}\schema\request\{module};

use OpenApi\Attributes as OA;
use madong\swagger\schema\BaseRequestDTO;
use WebmanTech\DTO\Attributes\ValidationRules;

/**
 * {Model}请求Schema
 */
#[OA\Schema(
    title: '{Model}请求',
    description: '{Model}相关请求参数'
)]
class {Model}Request extends BaseRequestDTO
{
    {properties}
}
```

## Complete Request Schema Example

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

namespace app\schema\request;

use OpenApi\Attributes as OA;
use madong\swagger\schema\BaseRequestDTO;
use WebmanTech\DTO\Attributes\ValidationRules;

#[OA\Schema(
    title: 'ID查询请求',
    description: '根据ID查询单条记录的请求参数'
)]
class IdRequest extends BaseRequestDTO
{
    #[OA\Property(
        property: 'id',
        description: '记录ID',
        type: 'string',
        example: 1
    )]
    #[ValidationRules(rules: 'string|required|min:1')]
    public int $id;
}
```

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

namespace app\schema\request;

use OpenApi\Attributes as OA;
use madong\swagger\schema\BaseRequestDTO;
use WebmanTech\DTO\Attributes\ValidationRules;

#[OA\Schema(
    title: '批量删除请求',
    description: '批量删除记录的请求参数'
)]
class BatchDeleteRequest extends BaseRequestDTO
{
    #[OA\Property(
        property: 'ids',
        description: '要删除的ID列表',
        type: 'array',
        items: new OA\Items(type: 'integer'),
        example: [1, 2, 3]
    )]
    #[ValidationRules(rules: 'required|array|min:1')]
    public array $ids;
}
```

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

namespace app\schema\request;

use OpenApi\Attributes as OA;
use madong\swagger\schema\BaseRequestDTO;
use WebmanTech\DTO\Attributes\ValidationRules;

#[OA\Schema(
    title: '状态更新请求',
    description: '更新记录状态的请求参数'
)]
class ChangeStatusRequest extends BaseRequestDTO
{
    #[OA\Property(
        property: 'id',
        description: '记录ID',
        type: 'integer',
        example: 1
    )]
    #[ValidationRules(rules: 'required|integer|min:1')]
    public int $id;

    #[OA\Property(
        property: 'status',
        description: '状态值',
        type: 'integer',
        example: 1
    )]
    #[ValidationRules(rules: 'required|in:0,1')]
    public int $status;
}
```

## Common Request Schemas

### IdRequest - ID查询请求
```php
#[OA\Schema(title: 'ID查询请求')]
class IdRequest extends BaseRequestDTO
{
    #[OA\Property(property: 'id', description: '记录ID', type: 'integer')]
    #[ValidationRules(rules: 'integer|required|min:1')]
    public int $id;
}
```

### BatchDeleteRequest - 批量删除请求
```php
#[OA\Schema(title: '批量删除请求')]
class BatchDeleteRequest extends BaseRequestDTO
{
    #[OA\Property(property: 'ids', description: 'ID列表', type: 'array', items: new OA\Items(type: 'integer'))]
    #[ValidationRules(rules: 'required|array|min:1')]
    public array $ids;
}
```

### ChangeStatusRequest - 状态更新请求
```php
#[OA\Schema(title: '状态更新请求')]
class ChangeStatusRequest extends BaseRequestDTO
{
    #[OA\Property(property: 'id', description: 'ID', type: 'integer')]
    public int $id;

    #[OA\Property(property: 'status', description: '状态', type: 'integer', example: 1)]
    public int $status;
}
```

### PageRequest - 分页请求
```php
#[OA\Schema(title: '分页请求')]
class PageRequest extends BaseRequestDTO
{
    #[OA\Property(property: 'page', description: '页码', type: 'integer', example: 1)]
    #[ValidationRules(rules: 'integer|min:1')]
    public int $page = 1;

    #[OA\Property(property: 'limit', description: '每页数量', type: 'integer', example: 10)]
    #[ValidationRules(rules: 'integer|min:1|max:100')]
    public int $limit = 10;
}
```

## Response Schema Template

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

namespace {ns}\schema\response\{module};

use OpenApi\Attributes as OA;

/**
 * {Model}响应Schema
 */
#[OA\Schema(
    title: '{Model}响应',
    description: '{Model}相关响应数据'
)]
class {Model}Response
{
    #[OA\Property(property: 'id', description: 'ID', type: 'integer')]
    public int $id;

    {properties}
}
```

## Common Response Schemas

### ListResponse - 列表响应
```php
#[OA\Schema(
    title: '列表响应',
    description: '分页列表响应'
)]
class ListResponse
{
    #[OA\Property(property: 'total', description: '总数', type: 'integer', example: 100)]
    public int $total;

    #[OA\Property(property: 'list', description: '列表数据', type: 'array', items: new OA\Items())]
    public array $list;
}
```

### PageResponse - 分页响应
```php
#[OA\Schema(
    title: '分页响应',
    description: '分页响应数据'
)]
class PageResponse
{
    #[OA\Property(property: 'total', description: '总数', type: 'integer')]
    public int $total;

    #[OA\Property(property: 'list', description: '列表数据', type: 'array', items: new OA\Items())]
    public array $list;

    #[OA\Property(property: 'page', description: '当前页', type: 'integer')]
    public int $page;

    #[OA\Property(property: 'limit', description: '每页数量', type: 'integer')]
    public int $limit;
}
```

## Auto-generation Checklist

When generating Schema:
- [ ] Set correct namespace based on target
- [ ] Import BaseRequestDTO or BaseResponseDTO
- [ ] Import OpenApi\Attributes as OA
- [ ] Import ValidationRules attribute
- [ ] Add #[OA\Schema] class attribute
- [ ] Add #[OA\Property] for each property
- [ ] Add #[ValidationRules] for validation
- [ ] Define property type and default value
