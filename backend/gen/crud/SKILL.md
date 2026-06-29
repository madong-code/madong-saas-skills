---
name: madong-gen-crud
description: Generates complete CRUD module for both main project (app) and plugins. Uses target parameter (app/plugin) to determine paths. This skill orchestrates sub-skills to generate migrations, models, controllers, services, DAOs, validates, schemas, Vue frontend pages, and route configuration.
globs:
  - "app/**/*.php"
  - "app/**/resource/**/*.vue"
  - "frontend/admin/src/apps/**/*.ts"
  - "plugin/**/*.php"
  - "plugin/**/resource/**/*.vue"
---

# madong CRUD Generator

Generate complete CRUD module with one command - from table definition to full backend and frontend implementation.

## Target: App vs Plugin

| 特性 | App (主项目) | Plugin (插件) |
|------|-------------|---------------|
| **命名空间前缀** | `app\{module}\...` | `plugin\{Plugin}\app\...` |
| **Model 基类** | `core\foundation\base\BaseModel` | `plugin\{Plugin}\app\model\BaseModel` |
| **Controller 基类** | `app\adminapi\controller\Crud` | `app\adminapi\controller\Crud` |
| **API Controller** | 纯类（不继承） | 纯类（不继承） |
| **DAO 基类** | `core\foundation\base\BaseDao` | `core\foundation\base\BaseDao` |
| **Service 基类** | `core\foundation\base\BaseService` | `core\foundation\base\BaseService` |
| **Validate 基类** | `core\base\BaseValidate` | `core\base\BaseValidate` |
| **Migration** | `Builder $schema` 模式 | `Builder $schema` 模式 |
| **前端路径** | `frontend/admin/src/apps/{module}/` | `resource/template/admin/views/{module}/` |
| **多语言路径** | `resource/translations/` | `plugin/{plugin}/resource/translations/` |

> **注意**: 基于 portal 实际实现的模式更新：
> - 所有 `core\base\*` 改为 `core\foundation\base\*`
> - API 控制器不使用基类，为纯类
> - API 服务层使用 `plugin\{Plugin}\app\api\service\{module}` 命名空间
> - Migration 使用 `Builder $schema` 模式（不继承 Migration 基类）

## Input: Table Definition

```markdown
Module: Ask
Target: app  # 或 plugin
Table: questions
Fields:
- id (primary key, snowflake)
- name (string, 100, required)
- category_id (foreign key -> categories)
- description (text, nullable)
- price (decimal 10,2, required)
- stock (integer, default 0)
- status (tinyint, default 1)
```

### 特殊标记

| 标记 | 说明 |
|------|------|
| `snowflake` | 使用雪花ID作为主键 (默认) |
| `no-api` | 不生成前台API |
| `public-create` | 允许公开创建（无需登录） |

---

## Output: Complete Module Structure

### App (主项目)

```
app/
├── adminapi/
│   ├── controller/{module}/{Model}Controller.php
│   └── validate/{module}/{Model}Validate.php
├── api/
│   ├── controller/{module}/{Model}Controller.php
│   └── service/{module}/{Model}Service.php
├── service/
│   └── admin/{module}/{Model}Service.php
├── dao/{module}/{Model}Dao.php
├── model/{module}/{Model}.php
├── schema/
│   ├── request/{module}/{Model}Request.php
│   └── response/{module}/{Model}Response.php
└── config/
    └── route.php

resource/
├── database/
│   └── migrations/{timestamp}_create_{table_name}_table.php
└── translations/
    ├── zh_CN/{module}.php
    └── en/{module}.php

frontend/admin/src/apps/{module}/
├── views/{model}/
│   ├── index.vue
│   ├── form.vue
│   └── schemas/index.tsx
├── api/{module}/index.ts
└── locales/lang/
    ├── zh-cn/{module}.json
    └── en/{module}.json
```

### Plugin (插件)

```
plugin/{plugin}/
├── app/
│   ├── adminapi/
│   │   ├── controller/{module}/{Model}Controller.php
│   │   └── validate/{module}/{Model}Validate.php
│   ├── api/
│   │   ├── controller/{module}/{Model}Controller.php
│   │   └── service/{module}/{Model}Service.php
│   ├── adminapi/
│   │   ├── controller/{module}/{Model}Controller.php
│   │   ├── validate/{module}/{Model}Validate.php
│   │   └── service/{module}/{Model}Service.php
│   ├── dao/{module}/{Model}Dao.php
│   ├── model/{module}/{Model}.php
│   └── schema/
│       ├── request/{module}/{Model}Request.php
│       └── response/{module}/{Model}Response.php
├── config/
│   └── route.php
└── resource/
    ├── database/
    │   └── migrations/{timestamp}_create_{table_name}_table.php
    └── translations/
        ├── zh_CN/{module}.php
        └── en/{module}.php
```

---

## Path Variables

根据 `target` 参数，路径变量替换如下：

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{base}` | `app` | `plugin/{plugin}/app` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{model_ns}` | `app\model` | `plugin\{Plugin}\app\model` |
| `{dao_ns}` | `app\dao` | `plugin\{Plugin}\app\dao` |
| `{service_ns}` | `app\service\admin` | `plugin\{Plugin}\app\service\admin` |
| `{api_service_ns}` | `app\api\service` | `plugin\{Plugin}\app\api\service` |
| `{validate_ns}` | `app\adminapi\validate` | `plugin\{Plugin}\app\adminapi\validate` |

### 完整路径映射（基于 portal 实际实现）

| 文件类型 | App 路径 | Plugin 路径 |
|----------|----------|-------------|
| Model | `app/model/{module}/{Model}.php` | `plugin/{plugin}/app/model/{module}/{Model}.php` |
| Admin Controller | `app/adminapi/controller/{module}/{Model}Controller.php` | `plugin/{plugin}/app/adminapi/controller/{module}/{Model}Controller.php` |
| Admin Service | `app/service/admin/{module}/{Model}Service.php` | `plugin/{plugin}/app/service/admin/{module}/{Model}Service.php` |
| API Controller | `app/api/controller/{module}/{Model}Controller.php` | `plugin/{plugin}/app/api/controller/{module}/{Model}Controller.php` |
| API Service | `app/api/service/{module}/{Model}Service.php` | `plugin/{plugin}/app/api/service/{module}/{Model}Service.php` |
| Validate | `app/adminapi/validate/{module}/{Model}Validate.php` | `plugin/{plugin}/app/adminapi/validate/{module}/{Model}Validate.php` |
| DAO | `app/dao/{module}/{Model}Dao.php` | `plugin/{plugin}/app/dao/{module}/{Model}Dao.php` |
| Schema Request | `app/schema/request/{module}/{Model}Request.php` | `plugin/{plugin}/app/schema/request/{module}/{Model}Request.php` |
| Schema Response | `app/schema/response/{module}/{Model}Response.php` | `plugin/{plugin}/app/schema/response/{module}/{Model}Response.php` |
| Migration | `resource/database/migrations/*.php` | `resource/database/migrations/*.php` |

---

## Pre-checks (执行前)

- **Target 确认**: 用户未指定时，询问是主项目(app)还是插件(plugin)
- **Module 存在性**: 若目录不存在，需要创建目录结构
- **文件冲突**: 目标文件已存在时，先询问覆盖或增量修改
- **依赖检查**: 检查外键关联的模型是否存在
- **API 支持**: 询问是否需要生成前台 API

---

## Output Contract (输出契约)

- 必须生成所有步骤的完整产物（除非使用 `no-api` 标记）
- 所有路径、类名、命名空间与 `{Module}/{Model}/{table}` 一致
- 前端 API 路径与后端路由前缀保持一致
- 使用雪花ID作为主键（`bigInteger('id')->primary()`）
- Validate 使用 Laravel Validation 规则
- Schema 使用 OpenAPI 属性定义
- DAO 继承 `core\foundation\base\BaseDao`，实现 `setModel()` 方法
- Admin Service 继承 `core\foundation\base\BaseService`，注入 DAO
- API Service 继承 `core\foundation\base\BaseService`，使用自定义业务方法

---

## Consistency Validation (生成后校验)

- Migration 主键使用 `$table->bigInteger('id')->primary()` 支持雪花ID（使用 Builder $schema 模式）
- Migration 时间戳使用 `bigInteger`（非 `unsignedInteger`）
- Migration 添加 `tenant_id` 多租户支持
- Migration 设置 InnoDB + utf8mb4
- Model `$fillable` 与 Migration 字段一致，使用 `SoftDeletes` trait
- Model `$casts` 正确设置字段类型转换（雪花ID使用 `'string'`）
- Model `$incrementing = false`（非自增）
- Admin Controller 使用 `Crud` 基类，`#[Permission(code: '...')]` 注解
- API Controller 为纯类（不继承基类），注入 `CurrentMember`
- Validate 使用 `BaseValidate` 基类，定义 rules、message、scene（可选生成）
- DAO 的 `setModel()` 返回正确的模型类
- Admin Service 注入对应 DAO，通过 `__call` 自动代理
- API Service 使用自定义业务方法（getList/detail/create/update/delete）
- Schema 使用 `BaseRequestDTO`/`BaseResponseDTO`，添加 OpenAPI 属性（plugin 可空）
- Route `/api` 和 `/adminapi` 分别注册 Swagger

---

## Fallback Rules (失败兜底)

- 输入缺失关键字段（如 table/fields）时必须先澄清
- 复杂关系或非标准业务逻辑需用户确认后再生成
- 外键关联的表不存在时应询问是否创建

---

## Workflow

### Step 1: Parse Table Definition → `01-parse-table`

Extract from user input:
- Target (app 或 plugin)
- Plugin name (snake_case) - 仅 plugin 模式
- Module name (PascalCase)
- Model name (PascalCase singular)
- Table name (snake_case)
- Fields with types, constraints, and relationships
- Special flags: `snowflake`, `no-api`, `public-create`

### Step 2: Generate Migration → `02-migration`

> **重要**: 主键使用 `$table->bigInteger('id')->primary()`（不使用 unsigned）

```php
$table->bigInteger('id')->primary()->comment('雪花ID主键');
// 时间戳也使用 bigInteger
$table->bigInteger('created_at')->nullable()->comment('创建时间');
$table->bigInteger('updated_at')->nullable()->comment('更新时间');
$table->bigInteger('deleted_at')->nullable()->comment('删除时间');
```

### Step 3: Generate Model → `03-model`

> 使用 `core\base\BaseModel` 基类，`SoftDeletes` trait

### Step 4: Generate Validate → `04-validate`

> 使用 `core\base\BaseValidate` 基类（可选，portal 中可能为空目录）

### Step 5: Generate DAO → `05-dao`

> 使用 `core\foundation\base\BaseDao` 基类，实现 `setModel()` 方法

### Step 6: Generate Admin Service → `06-service`

> 使用 `core\foundation\base\BaseService` 基类，注入 DAO

### Step 7: Generate Admin Controller → `04-controller`

> 继承 `app\adminapi\controller\Crud`，添加 OpenAPI 属性和权限注解

### Step 8: Generate Schema → `08-schema`

> 使用 `BaseRequestDTO`/`BaseResponseDTO`，添加 OpenAPI 属性（plugin 可跳过）

### Step 9: Generate API Controller (可选) → `09-api-controller`

> 纯类（不继承基类），注入 `{Model}Service` 和 `CurrentMember`

### Step 10: Generate API Service (可选) → `10-api-service`

> 使用 `core\foundation\base\BaseService`，自定义业务方法

### Step 11: Generate Route → `11-route`

> 配置 `/api` 和 `/adminapi` 两组 Swagger 扫描路径

---

## API Controller Support (前台 API)

### 前台 API 特点

| 特点 | 说明 |
|------|------|
| 纯类实现 | 不继承基类，使用 `support\Request/Response` |
| 会员获取 | 注入 `CurrentMember` 或 `Container::make(CurrentMember::class)` |
| 数据隔离 | Service 层检查会员归属 |
| 雪花ID | 使用 `string $id` 接收雪花ID |
| JSON 响应 | 使用 `core\foundation\tool\Json::success/fail` |
| Swagger 注解 | 使用 `PageResponse`/`SimpleResponse` 注解 |

### API 路由示例

```
GET   /{api_prefix}           # 公开 - 获取列表
GET   /{api_prefix}/{id}       # 公开 - 获取详情
POST  /{api_prefix}            # 会员 - 创建
PUT   /{api_prefix}/{id}       # 会员 - 更新
DELETE /{api_prefix}/{id}       # 会员 - 删除
```

---

## Boundaries

- ✅ **Always**: Generate all files, follow madong conventions
- ✅ **Always**: Use bigInteger for primary key (snowflake ID support)
- ✅ **Always**: Use `$table->bigInteger('id')->primary()` (no unsigned)
- ✅ **Always**: Use SoftDeletes for all models
- ✅ **Always**: Use `bigInteger` for timestamps (not unsignedInteger)
- ✅ **Always**: Add `tenant_id` for SaaS multi-tenant support
- ✅ **Always**: Set InnoDB + utf8mb4 in migrations
- ✅ **Always**: Snowflake ID casts to `'string'` in Model
- ✅ **Always**: Laravel Validation rules in Validate
- ✅ **Always**: OpenAPI attributes in Controller and Schema
- ✅ **Always**: `core\foundation\base\BaseDao` with `setModel()` method
- ✅ **Always**: Inject DAO in Admin Service constructor
- ✅ **Always**: `core\foundation\base\BaseService` for services
- ✅ **Always**: Route with Swagger configuration (`/api` + `/adminapi`)
- ✅ **Always**: Respect target parameter (app/plugin)
- ⚠️ **Ask first**: Complex relationships, pivot tables, custom business logic
- ⚠️ **Ask first**: Whether API support is needed
- 🚫 **Never**: Extend API controller from base class
- 🚫 **Never**: Use `core\base\*` (migrated to `core\foundation\base\*`)
- 🚫 **Never**: Use Laravel default `id()` method for primary key

---

## Quick Commands

| Command | Description |
|---------|------------|
| `create CRUD for questions` | Create complete question CRUD (prompt for target) |
| `create CRUD for questions app` | Create CRUD for main project |
| `create CRUD for questions plugin` | Create CRUD for plugin |
| `create CRUD for questions no-api` | Create CRUD without API frontend |
| `add fields to questions` | Add fields to existing question table |
| `generate model for questions` | Generate model only |
| `generate dao for questions` | Generate DAO only |
| `generate service for questions` | Generate service only |
| `generate controller for questions` | Generate controller only |
| `generate validate for questions` | Generate validate only |
| `generate schema for questions` | Generate schema only |
| `generate route for questions` | Generate/update route only |
