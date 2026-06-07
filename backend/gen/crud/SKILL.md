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
| **Model 基类** | `core\base\BaseModel` | `plugin\{Plugin}\app\model\BaseModel` |
| **Controller 基类** | `app\adminapi\controller\Crud` | `app\adminapi\controller\Crud` |
| **API Controller 基类** | `app\api\controller\Base` | `app\api\controller\Base` |
| **DAO 基类** | `core\base\BaseDao` | `core\base\BaseDao` |
| **Service 基类** | `core\base\BaseService` | `core\base\BaseService` |
| **Validate 基类** | `core\base\BaseValidate` | `core\base\BaseValidate` |
| **Migration 路径** | `resource/database/migrations/` | `resource/database/migrations/` |
| **前端路径** | `frontend/admin/src/apps/{module}/` | `resource/template/admin/views/{module}/` |
| **多语言路径** | `resource/translations/` | `plugin/{plugin}/resource/translations/` |

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
│   └── validate/{module}/{Model}Validate.php
├── service/
│   ├── admin/{module}/{Model}Service.php
│   └── api/{module}/{Model}Service.php
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
│   │   └── validate/{module}/{Model}Validate.php
│   ├── service/
│   │   ├── admin/{module}/{Model}Service.php
│   │   └── api/{module}/{Model}Service.php
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
| `{validate_ns}` | `app\adminapi\validate` | `plugin\{Plugin}\app\adminapi\validate` |

### 完整路径映射

| 文件类型 | App 路径 | Plugin 路径 |
|----------|----------|-------------|
| Model | `app/model/{module}/{Model}.php` | `plugin/{plugin}/app/model/{module}/{Model}.php` |
| Controller | `app/adminapi/controller/{module}/{Model}Controller.php` | `plugin/{plugin}/app/adminapi/controller/{module}/{Model}Controller.php` |
| API Controller | `app/api/controller/{module}/{Model}Controller.php` | `plugin/{plugin}/app/api/controller/{module}/{Model}Controller.php` |
| Validate | `app/adminapi/validate/{module}/{Model}Validate.php` | `plugin/{plugin}/app/adminapi/validate/{module}/{Model}Validate.php` |
| Service | `app/service/admin/{module}/{Model}Service.php` | `plugin/{plugin}/app/service/admin/{module}/{Model}Service.php` |
| API Service | `app/service/api/{module}/{Model}Service.php` | `plugin/{plugin}/app/service/api/{module}/{Model}Service.php` |
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
- 使用雪花ID作为主键（`bigInteger('id')->unsigned()->primary()`）
- Validate 使用 Laravel Validation 规则
- Schema 使用 OpenAPI 属性定义
- DAO 继承 `core\base\BaseDao`，实现 `setModel()` 方法
- Service 继承 `core\base\BaseService`，注入 DAO

---

## Consistency Validation (生成后校验)

- Migration 主键使用 `bigInteger('id')->unsigned()->primary()` 支持雪花ID
- Model `$fillable` 与 Migration 字段一致，使用 `SoftDeletes` trait
- Model `$casts` 正确设置字段类型转换
- Controller 的 `$this->service` 正确注入
- Controller 使用 `Crud` 基类，继承标准 CRUD 方法
- Validate 使用 `BaseValidate` 基类，定义 rules、message、scene
- DAO 的 `setModel()` 返回正确的模型类
- Service 注入对应 DAO，实现业务逻辑
- Schema 使用 `BaseRequestDTO`/`BaseResponseDTO`，添加 OpenAPI 属性
- Frontend API 路径与后端路由一致
- Route 配置正确注册 Swagger 扫描路径

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

> **重要**: 主键必须使用 `bigInteger` 支持雪花ID

```php
$table->bigInteger('id')->unsigned()->primary();
```

### Step 3: Generate Model → `03-model`

> 使用 `core\base\BaseModel` 基类，`SoftDeletes` trait

### Step 4: Generate Validate → `04-validate`

> 使用 `core\base\BaseValidate` 基类

### Step 5: Generate DAO → `06-dao`

> 使用 `core\base\BaseDao` 基类，实现 `setModel()` 方法

### Step 6: Generate Service → `05-service`

> 使用 `core\base\BaseService` 基类，注入 DAO

### Step 7: Generate Controller → `04-controller`

> 继承 `app\adminapi\controller\Crud`，添加 OpenAPI 属性和权限注解

### Step 8: Generate Schema → `08-schema`

> 使用 `BaseRequestDTO`/`BaseResponseDTO`，添加 OpenAPI 属性

### Step 9: Generate Route → `09-route`

> 配置 Swagger 扫描路径

### Step 10: Generate Frontend → `07-frontend`

> 生成 Vue 页面和 API 调用代码

---

## API Controller Support (前台 API)

### 前台 API 特点

| 特点 | 说明 |
|------|------|
| 继承 Base | 继承 `app\api\controller\Base` |
| 公开访问 | 列表和详情使用 `#[AllowAnonymous]` |
| 会员操作 | 创建、更新、删除使用 `#[MemberAuthRequired]` |
| 数据隔离 | 支持会员数据隔离和权限检查 |
| 雪花ID | 使用雪花ID作为主键 |

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
- ✅ **Always**: Use SoftDeletes for all models
- ✅ **Always**: Use unsignedInteger for timestamps
- ✅ **Always**: Use Laravel Validation rules in Validate
- ✅ **Always**: Use OpenAPI attributes in Controller and Schema
- ✅ **Always**: Use BaseDao with setModel() method
- ✅ **Always**: Inject DAO in Service constructor
- ✅ **Always**: Generate Schema for API documentation
- ✅ **Always**: Generate Route with Swagger configuration
- ✅ **Always**: Respect target parameter (app/plugin)
- ⚠️ **Ask first**: Complex relationships, pivot tables, custom business logic
- ⚠️ **Ask first**: Whether API support is needed
- 🚫 **Never**: Skip validation, ignore foreign key constraints
- 🚫 **Never**: Use Laravel default id() method for primary key

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
