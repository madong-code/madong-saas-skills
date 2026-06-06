---
name: madong-backend-schema
description: Schema DTO 规范 - 请求DTO和响应DTO，用于参数校验和API文档
globs:
  - "app/**/schema/**/*.php"
---

## 文件位置

```
app/
├── schema/                              # 跨端共享 DTO
│   ├── request/
│   │   ├── BatchDeleteRequest.php
│   │   ├── CommonQueryRequest.php
│   │   └── ...
│   └── response/
│       └── ...
└── {adminapi|platform|api}/
    └── schema/                          # 端专属 DTO
        ├── request/{module}/
        │   └── {Model}{Action}Request.php
        └── response/{module}/
            └── {Model}Response.php
```

## 代码模板

### Request DTO

```php
<?php
declare(strict_types=1);

namespace app\adminapi\schema\request\{module};

use madong\swagger\annotation\request\BaseRequestDTO;
use madong\swagger\annotation\ValidationRules;
use OpenApi\Attributes as OA;

#[OA\Schema(schema: '{Model}{Action}Request')]
class {Model}{Action}Request extends BaseRequestDTO
{
    #[OA\Property(property: 'name', description: '名称', type: 'string')]
    #[ValidationRules(['required', 'max:50'])]
    public ?string $name = null;

    #[OA\Property(property: 'status', description: '状态 1-开启 0-关闭', type: 'integer')]
    #[ValidationRules(['numeric', 'in:0,1'])]
    public ?int $status = null;

    #[OA\Property(property: 'sort', description: '排序', type: 'integer')]
    #[ValidationRules(['numeric'])]
    public ?int $sort = null;
}
```

### Response DTO

```php
<?php
declare(strict_types=1);

namespace app\adminapi\schema\response\{module};

use OpenApi\Attributes as OA;

#[OA\Schema(schema: '{Model}Response')]
class {Model}Response
{
    #[OA\Property(property: 'id', description: 'ID', type: 'integer')]
    public int $id;

    #[OA\Property(property: 'name', description: '名称', type: 'string')]
    public string $name;

    #[OA\Property(property: 'status', description: '状态', type: 'integer')]
    public int $status;

    #[OA\Property(property: 'sort', description: '排序', type: 'integer')]
    public int $sort;

    #[OA\Property(property: 'created_at', description: '创建时间', type: 'integer')]
    public int $created_at;
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system/member/content 等 |
| `{Model}` | Menu/Member 等 |
| `{Action}` | Create/Update/Query 等 |

## 关键约定

- Request DTO 必须继承 `BaseRequestDTO`，声明 `#[OA\Schema]` 和 `#[ValidationRules]`
- Response DTO 必须声明 `#[OA\Schema]`，属性使用 `#[OA\Property]`
- 扫描路径：`base_path('app')`（框架自动扫描 controller/schema 目录）
- 请求 DTO 属性名使用 snake_case
- `BaseRequestDTO` 提供 `toArray()` / `only()` 等方法
- `#[ValidationRules]` 支持所有 Laravel 验证规则

## 检查清单

- [ ] Request DTO 是否继承 `BaseRequestDTO`
- [ ] 是否声明了 `#[OA\Schema]` 和 `#[ValidationRules]`
- [ ] Response DTO 是否声明了 `#[OA\Schema]` 和 `#[OA\Property]`
- [ ] 属性名是否使用 snake_case
- [ ] 命名空间是否正确
