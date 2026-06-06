---
name: madong-backend-route
description: 路由配置规范，通过 Swagger 注解自动注册路由
globs:
  - "app/**/config/route.php"
---

## 文件位置

```
app/{app}/config/route.php
```

| 端 | 路径 | 路由前缀 |
|----|------|---------|
| AdminAPI | `app/adminapi/config/route.php` | `/adminapi` |
| Platform | `app/platform/config/route.php` | `/platformapi` |
| API | `app/api/config/route.php` | `/api` |

## 路由注册方式

本项目使用 **Swagger/OpenAPI 注解自动注册路由**，不手动定义路由规则。

### 注解方式（推荐）

```php
use OpenApi\Attributes as OA;

#[OA\Get(path: '/adminapi/system/menu', summary: '菜单列表')]
public function index(Request $request): \Json
{
    // ...
}
```

### 手动注册方式（仅在需要特殊路由时使用）

```php
<?php

use Webman\Route;

// 注意：不要在外层再包 /adminapi 路由组！
Route::group('/adminapi/system/menu', function () {
    Route::post('export', [app\adminapi\controller\system\MenuController::class, 'export']);
});
```

## 关键约定

- **优先使用 Swagger 注解**注册路由，`#[OA\Get]`/`#[OA\Post]`/`#[OA\Put]`/`#[OA\Delete]` 自动完成
- 路由文件自身**不要**在外层包 `/adminapi` 路由组（主路由文件已经包过）
- 手动路由仅用于特殊路径（如 export、changeStatus 等非标准 CRUD）
- Swagger 扫描路径在配置中指定，覆盖 `base_path('app')`
- 路由 code（菜单权限定义）在 `resource/data/menu/{app}.php` 中配置
- 开发环境文档访问：`{host}/app-api/swagger`

## 路由扫描配置

```php
// config/route.php（框架层）
'annotation' => [
    'paths' => [
        base_path('app'),
    ],
],
```

## 检查清单

- [ ] 是否优先使用 Swagger 注解注册路由
- [ ] 手动路由是否没有在外层包 `/adminapi` 路由组
- [ ] 手动路由是否只在「非标准 CRUD」时使用
- [ ] 路由 code 是否已在 `resource/data/menu/{app}.php` 中配置
