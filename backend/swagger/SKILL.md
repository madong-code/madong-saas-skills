---
name: madong-backend-swagger
description: Swagger/OpenAPI 注解规范，用于自动注册路由和生成API文档
globs:
  - "app/**/*.php"
---

## 文件位置

Swagger 注解直接写在控制器和 Schema DTO 中，无需独立文件。

## 注解类型

### 控制器类注解（路由分组）

```php
use OpenApi\Attributes as OA;

#[OA\Tag(name: '系统管理', description: '系统管理相关接口')]
#[OA\Info(version: '1.0.0', title: 'Madong AdminAPI')]
#[OA\Server(url: 'http://localhost:8500', description: '开发环境')]
#[OA\SecurityScheme(securityScheme: 'BearerAuth', type: 'http', scheme: 'bearer')]
class MenuController extends Crud
```

### 控制器方法注解（路由注册+文档）

```php
use OpenApi\Attributes as OA;

#[OA\Get(path: '/adminapi/system/menu', summary: '菜单列表')]
#[OA\Tag(name: '系统管理')]
#[OA\Parameter(name: 'page', in: 'query', schema: new OA\Schema(type: 'integer'))]
#[OA\Parameter(name: 'limit', in: 'query', schema: new OA\Schema(type: 'integer'))]
#[OA\Response(response: 200, description: '成功')]
public function index(Request $request): \Json
{
    return parent::index($request);
}

#[OA\Post(path: '/adminapi/system/menu', summary: '创建菜单')]
#[OA\RequestBody(content: new OA\JsonContent(ref: '#/components/schemas/MenuFormRequest'))]
#[OA\Response(response: 200, description: '成功')]
public function store(Request $request): \Json
{
    return parent::store($request);
}
```

### Schema DTO 注解（请求/响应结构定义）

```php
use OpenApi\Attributes as OA;

#[OA\Schema(schema: 'MenuFormRequest')]
class MenuFormRequest extends BaseRequestDTO
{
    #[OA\Property(property: 'name', description: '菜单名称', type: 'string')]
    public ?string $name = null;
}
```

## 注解映射关系

| 注解 | 用途 |
|------|------|
| `#[OA\Get]` | GET 路由注册 + API 文档 |
| `#[OA\Post]` | POST 路由注册 + API 文档 |
| `#[OA\Put]` | PUT 路由注册 + API 文档 |
| `#[OA\Delete]` | DELETE 路由注册 + API 文档 |
| `#[OA\Tag]` | 接口分组标签 |
| `#[OA\Schema]` | DTO 结构定义 |
| `#[OA\Property]` | DTO 属性定义 |
| `#[OA\Parameter]` | 请求参数 |
| `#[OA\RequestBody]` | 请求体 |
| `#[OA\Response]` | 响应 |

## 关键约定

- **`#[OA\Get/Post/Put/Delete]` 中的 path 同时作为路由注册路径**
- path 格式：`/{prefix}/{module}/{action}`（如 `/adminapi/system/menu`）
- 方法名使用小驼峰，path 使用 kebab-case
- Schema DTO 的 `#[OA\Schema(schema: '...')]` 名称使用 `{Model}{Action}Request` 格式
- 所有公开方法必须包含 `#[OA\Get/Post/Put/Delete]` 注解（否则不会注册路由）
- Annotation 扫描路径：`base_path('app')`
- 开发环境文档地址：`{host}/app-api/swagger`

## 检查清单

- [ ] 控制器类上是否声明了 `#[OA\Tag]`
- [ ] 每个方法是否都有 `#[OA\Get/Post/Put/Delete]` 注解
- [ ] path 格式是否为 `/{prefix}/{module}/{action}`
- [ ] Schema DTO 是否都有 `#[OA\Schema]` 注解
- [ ] 权限码是否与路由 path 对应
