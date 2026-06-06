---
name: madong-backend-middleware
description: 中间件规范，全局/AdminAPI/Platform 三层
globs:
  - "app/**/middleware/**/*.php"
---

## 文件位置

| 层 | 路径 | 注册方式 |
|----|------|---------|
| 全局 | `app/middleware/` | `config/middleware.php` |
| AdminAPI | `app/adminapi/middleware/` | `#[Middleware]` 注解 |
| Platform | `app/platform/middleware/` | `#[Middleware]` 注解 |

## 中间件层次

### 1. 全局中间件 (`config/middleware.php`)

```php
return [
    // 跨域
    app\middleware\CrossDomainMiddleware::class,
    // 请求格式处理
    app\middleware\RequestFormatMiddleware::class,
    // API 版本
    app\middleware\ApiVersionMiddleware::class,
];
```

### 2. AdminAPI 中间件（控制器注解）

```php
use support\annotation\Middleware;

// 在控制器类上声明
#[Middleware(AccessTokenMiddleware::class, PermissionMiddleware::class, OperationMiddleware::class)]
class {Model}Controller extends Crud
```

### 3. 常用中间件列表

| 中间件 | 类名 | 说明 |
|--------|------|------|
| 访问令牌 | `AccessTokenMiddleware` | JWT Token 验证 |
| 权限验证 | `PermissionMiddleware` | 权限码检查 |
| 操作日志 | `OperationMiddleware` | 自动记录操作日志 |
| 跨域 | `CrossDomainMiddleware` | CORS 跨域 |
| SSE Helper | `SseHelper` | SSE 连接辅助 |

## 中间件模板

```php
<?php
declare(strict_types=1);

namespace app\middleware\{module};

use Webman\Http\Request;
use Webman\Http\Response;
use Webman\MiddlewareInterface;

class {Name}Middleware implements MiddlewareInterface
{
    public function process(Request $request, callable $handler): Response
    {
        // 前置处理
        // ...

        $response = $handler($request);

        // 后置处理
        // ...

        return $response;
    }
}
```

## 关键约定

- 全局中间件在 `config/middleware.php` 中注册
- 控制器级中间件使用 `#[Middleware]` 属性注解
- 中间件执行顺序：控制器级别 → 应用级别 → 全局级别
- SSO/Auth 相关中间件放在应用目录下（如 `app/adminapi/middleware/`）
- 全局通用中间件（跨域/请求格式）放在 `app/middleware/` 下

## 检查清单

- [ ] 中间件是否注册到了正确的位置（全局/应用/控制器）
- [ ] 控制器上的 `#[Middleware]` 是否包含 AccessToken + Permission + Operation
- [ ] 中间件是否实现了 `MiddlewareInterface`
