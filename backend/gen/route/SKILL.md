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

## Plugin Route Template（基于 portal 实际实现）

> **注意**: portal 的 `/api` 和 `/adminapi` 路由直接注册，不嵌套在 `/{plugin_path}` 组下。两个路由组各自注册 Swagger，使用 `base_path()` 定位扫描路径。

```php
<?php
/**
 * This file is part of webman.
 * Licensed under The MIT License
 * For full copyright and license information, please see the MIT-LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @author    walkor<walkor@workerman.net>
 * @copyright walkor<walkor@workerman.net>
 * @link      http://www.workerman.net/
 * @license   http://www.opensource.org/licenses/mit-license.php MIT License
 */

use Webman\Route;
use WebmanTech\Swagger\Swagger;
use OpenApi\Annotations as OA;

/**
 * 注册API路由
 */
Route::group('/api', function () {
    Swagger::create()->registerRoute([
        'route_prefix'   => '/{plugin}/openapi',
        'register_route' => true,
        'openapi_doc'    => [
            'scan_path' => [
                base_path('app/schema'),
                base_path('plugin/{plugin}/app/api'),
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

Route::group('/adminapi', function () {
    Swagger::create()->registerRoute([
        'route_prefix'   => '/{plugin}/openapi',
        'register_route' => true,
        'openapi_doc'    => [
            'scan_path' => [
                base_path('app/schema'),
                base_path('plugin/{plugin}/app/adminapi'),
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
                        'name'           => config('core.jwt.app.token_name', 'Authorization'),
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

> **注意**: 使用 `base_path()` 定位插件路径（基于 portal 实现）

```php
// API 路由 scan_path
'scan_path' => [
    base_path('app/schema'),
    base_path('plugin/{plugin}/app/api'),
],

// AdminAPI 路由 scan_path
'scan_path' => [
    base_path('app/schema'),
    base_path('plugin/{plugin}/app/adminapi'),
],
```

## Auto-generation Checklist

When generating route:
- [ ] Create plugin/{plugin}/config/route.php
- [ ] `/api` 和 `/adminapi` 各自注册 Swagger（不嵌套在插件组下）
- [ ] Configure scan_path: `base_path('app/schema')` + `base_path('plugin/{plugin}/app/api')`
- [ ] Set correct security scheme: `config('core.jwt.app.token_name', 'Authorization')`
- [ ] Configure route_prefix: `/{plugin}/openapi`
- [ ] Configure server URL and description
- [ ] For plugins, use `base_path()` for paths
