---
name: madong-gen-route
description: Generate route configuration for madong module. Supports both app (main project) and plugin targets. Creates route.php files for adminapi and api with proper OpenAPI scan paths.
---

# Generate Route

Create route configuration files for modules.

## File Location

**App (主项目):**
```
app/adminapi/config/route.php
app/api/config/route.php
```

**Plugin (插件):**
```
plugin/{plugin}/config/route.php
```

## AdminAPI Route Template

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

use Webman\Route;
use WebmanTech\Swagger\Swagger;
use OpenApi\Annotations as OA;

/**
 * 注册admin API路由
 */
Route::group('/adminapi', function () {
    Swagger::create()->registerRoute([
        'route_prefix'   => '/openapi',
        'register_route' => true,
        'openapi_doc'    => [
            'scan_path' => [
                base_path('app/schema'),      // 基础schema
                base_path('app/adminapi'),
                base_path('app/install'),
            ],
            'modify'    => function (OA\OpenApi $openapi) {
                $openapi->info->title   = config('app.name') . ' API';
                $openapi->info->version = '1.0.0';
                $openapi->servers       = [
                    new OA\Server([
                        'url'         => '/adminapi',
                        'description' => request()->host(),
                    ]),
                ];

                if (!$openapi->components instanceof OA\Components) {
                    $openapi->components = new OA\Components([]);
                }

                $openapi->components->securitySchemes = [
                    new OA\SecurityScheme([
                        'securityScheme' => 'api_key',
                        'type'           => 'apiKey',
                        'name'           => config('madong.jwt.app.token_name', 'Authorization'),
                        'in'             => 'header',
                    ]),
                ];
            },
        ],
    ]);
});
```

## API Route Template

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

use Webman\Route;
use WebmanTech\Swagger\Swagger;
use OpenApi\Annotations as OA;

/**
 * 注册API路由
 */
Route::group('/api', function () {
    Swagger::create()->registerRoute([
        'route_prefix'   => '/openapi',
        'register_route' => true,
        'openapi_doc'    => [
            'scan_path' => [
                base_path('app/api'),
            ],
            'modify'    => function (OA\OpenApi $openapi) {
                $openapi->info->title   = config('app.name') . ' API';
                $openapi->info->version = '1.0.0';
                $openapi->servers       = [
                    new OA\Server([
                        'url'         => '/api',
                        'description' => request()->host(),
                    ]),
                ];

                if (!$openapi->components instanceof OA\Components) {
                    $openapi->components = new OA\Components([]);
                }

                $openapi->components->securitySchemes = [
                    new OA\SecurityScheme([
                        'securityScheme' => 'api_key',
                        'type'           => 'apiKey',
                        'name'           => config('core.jwt.app.token_name', 'Authorization'),
                        'in'             => 'header',
                    ]),
                ];
            },
        ],
    ]);
});
```

## Plugin Route Template

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

use Webman\Route;
use WebmanTech\Swagger\Swagger;
use OpenApi\Annotations as OA;

/**
 * 注册{Plugin}插件路由
 */
Route::group('/{plugin_path}', function () {
    // AdminAPI 路由
    Route::group('/adminapi', function () {
        // 控制器自动加载，无需手动注册
    });

    // API 路由
    Route::group('/api', function () {
        // 控制器自动加载，无需手动注册
    });

    // Swagger 文档注册
    Swagger::create()->registerRoute([
        'route_prefix'   => '/openapi',
        'register_route' => true,
        'openapi_doc'    => [
            'scan_path' => [
                // 插件的 adminapi 目录
                __DIR__ . '/app/adminapi',
                // 插件的 api 目录
                __DIR__ . '/app/api',
            ],
            'modify'    => function (OA\OpenApi $openapi) {
                $openapi->info->title   = '{Plugin} API';
                $openapi->info->version = '1.0.0';
                $openapi->servers       = [
                    new OA\Server([
                        'url'         => '/{plugin_path}',
                        'description' => request()->host(),
                    ]),
                ];

                if (!$openapi->components instanceof OA\Components) {
                    $openapi->components = new OA\Components([]);
                }

                $openapi->components->securitySchemes = [
                    new OA\SecurityScheme([
                        'securityScheme' => 'api_key',
                        'type'           => 'apiKey',
                        'name'           => config('madong.jwt.app.token_name', 'Authorization'),
                        'in'             => 'header',
                    ]),
                ];
            },
        ],
    ]);
});
```

## Route Auto-Discovery

Controllers are auto-loaded by webman based on naming convention:

| Controller | Auto Route |
|------------|------------|
| `adminapi/controller/member/MemberController.php` | `/adminapi/member/member` |
| `adminapi/controller/member/UserController.php` | `/adminapi/member/user` |
| `api/controller/auth/AuthController.php` | `/api/auth/auth` |

### Route Naming Convention

```
app/adminapi/controller/{module}/{Model}Controller.php
                                    ↓
                          /{module}/{model}
```

## Swagger Scan Path Configuration

### AdminAPI OpenAPI Scan

```php
'scan_path' => [
    base_path('app/schema'),      // Schema DTOs
    base_path('app/adminapi'),    // AdminAPI controllers, validates
    base_path('app/install'),     // Install controllers
],
```

### API OpenAPI Scan

```php
'scan_path' => [
    base_path('app/api'),         // API controllers
],
```

### Plugin OpenAPI Scan

```php
'scan_path' => [
    __DIR__ . '/app/adminapi',    // Plugin AdminAPI
    __DIR__ . '/app/api',         // Plugin API
],
```

## Auto-generation Checklist

When generating route:
- [ ] Create adminapi/config/route.php with Swagger
- [ ] Create api/config/route.php with Swagger
- [ ] Configure scan_path to include all relevant directories
- [ ] Set correct security scheme (Authorization header)
- [ ] Configure server URL and description
- [ ] For plugins, use __DIR__ for relative paths
