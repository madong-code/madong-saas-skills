# Madong SaaS Skills — 项目 AI 技能库

让 AI 理解你的项目规范。覆盖后端、前端、跨层三大领域，一键分发到各 AI 编辑器。

## 快速开始

```powershell
# 一键同步全部（默认）
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1

# 只同步你用的编辑器（推荐）
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target codebuddy
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target cursor
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target trae
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target copilot
```

执行后根据你使用的编辑器查看对应章节：

### CodeBuddy
1. 运行同步脚本
2. 打开 **设置 → 技能**，应看到所有技能
3. 对话中直接输入：`@backend-controller` 或描述需求自动触发

### Trae
| 功能 | 查看位置 | 文件位置 |
|------|---------|---------|
| **技能（Skills）** | 设置 → 技能 | `.agents/skills/{name}/SKILL.md` |
| **规则（Rules）** | 设置 → 规则与记忆 | `.trae/rules/{name}/rule.md` |

启动后自动加载，无需额外配置。

### Cursor
- 规则自动出现在 **Rules** 管理界面
- 重启后生效
- 文件：`.cursor/rules/{name}/rule.mdc`

### GitHub Copilot
- 所有规范聚合在 `.github/copilot-instructions.md`
- 自动读取，无需操作

---

## 一键同步（详细）

```powershell
# 同步全部
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1

# 或只同步特定编辑器（推荐）
powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target trae
```

脚本将所有技能分发到（根据 `-target` 参数过滤）：

| 编辑器 | 位置 | 格式 | 数量 |
|--------|------|------|------|
| **CodeBuddy** | `.codebuddy/skills/{name}/` | `{name}/SKILL.md` | - |
| **Cursor** | `.cursor/rules/{name}/` | `{name}/rule.mdc` | - |
| **Trae Rules** | `.trae/rules/{name}/` | `{name}/rule.md` | - |
| **Trae Skills** | `.agents/skills/{name}/` | `{name}/SKILL.md` | - |
| **GitHub Copilot** | `.github/copilot-instructions.md` | 聚合 Markdown | 1 |

> 每次修改 `madong-saas-skills/` 下的源文件后，重新运行脚本即可同步到所有编辑器。

---

## 技能源文件

```
madong-saas-skills/
├── README.md                     # ← 本文件
├── sync.ps1                       # ← 同步脚本
├── backend/                      # 后端 26 项
│   ├── controller/              # 控制器规范
│   ├── service/                 # 服务层规范
│   ├── dao/                     # 数据访问层
│   ├── model/                   # 模型规范
│   ├── validate/                # 验证器
│   ├── schema/                  # Schema DTO
│   ├── migrate/                 # 数据库迁移
│   ├── event/                   # 事件
│   ├── listener/                # 监听器
│   ├── route/                   # 路由
│   ├── lang/                    # 国际化
│   ├── logger/                  # 日志
│   ├── parse/                   # 表解析
│   ├── config/                  # 配置体系
│   ├── bootstrap/               # 启动引导
│   ├── enum/                    # 枚举
│   ├── middleware/              # 中间件
│   ├── scope/                   # 数据权限
│   ├── queue/                   # 队列
│   ├── process/                 # 自定义进程
│   ├── command/                 # 命令行
│   ├── crontab/                 # 定时任务
│   ├── swagger/                 # Swagger 注解
│   ├── generator/               # 代码生成器
│   ├── exception/               # 异常体系
│   └── tests/                   # 测试
├── frontend/                    # 前端 10 项
│   ├── common/                  # 公共规范
│   ├── api/                     # API 层
│   ├── adapter/                 # 适配器
│   ├── component/               # 公共组件
│   ├── i18n/                    # 国际化
│   ├── bootstrap/               # 启动引导
│   └── apps/
│       ├── view/                # 视图层
│       ├── router/              # 路由
│       ├── store/               # 状态管理
│       └── tests/               # 测试
└── cross/                       # 跨层 3 项
    ├── api-convention/          # API 对接规范
    ├── database/                # 数据库设计规范
    └── app-skeleton/            # 站点脚手架
```

---

## 按场景选择

不需要全部启用。按你的角色挑选：

| 场景 | 推荐技能 |
|------|---------|
| **写后端 CRUD** | controller + service + dao + model + validate + schema + route + swagger + enum |
| **写前端页面** | api + view + component + adapter + store + router + i18n |
| **整体项目开发** | 以上全部 + cross/api-convention + cross/database |
| **代码生成** | generator + parse + migrate |
| **运维/调试** | config + bootstrap + exception + logger + middleware + scope + command + crontab |

---

## 手动操作（不用脚本时）

只同步你需要的技能：

- **CodeBuddy**：复制到 `.codebuddy/skills/{name}/SKILL.md`
- **Cursor**：复制到 `.cursor/rules/{name}/rule.mdc`
- **Trae Rules**：复制到 `.trae/rules/{name}/rule.md`
- **Trae Skills**：复制到 `.agents/skills/{name}/SKILL.md`
- **Copilot**：内容聚合到 `.github/copilot-instructions.md`

---

## 项目通用规范（供 AI 参考）

你也可以将这些内容粘贴到编辑器的全局规则中。

### 命名总则

| 场景 | 规范 | 示例 |
|------|------|------|
| 控制器类 | 大驼峰 + `Controller` 后缀 | `MenuController`, `MemberController` |
| 服务类 | 大驼峰 + `Service` 后缀 | `MenuService`, `MemberService` |
| DAO类 | 大驼峰 + `Dao` 后缀 | `MenuDao`, `MemberDao` |
| 模型类 | 大驼峰（无后缀） | `Menu`, `Member` |
| 验证器类 | 大驼峰 + `Validate` 后缀 | `MenuValidate`, `MemberValidate` |
| Schema Request | 大驼峰 + `Request` 后缀 | `MenuCreateRequest`, `MemberUpdateRequest` |
| Schema Response | 大驼峰 + `Response` 后缀 | `MenuResponse`, `MemberResponse` |
| 事件类 | 大驼峰 + `Event` 后缀 | `MemberRegisterEvent`, `MenuUpdatedEvent` |
| 监听器类 | 大驼峰 + `Listener` 后缀 | `MemberRegisterListener`, `MenuUpdatedListener` |
| 枚举类 | 大驼峰 + `Enum` 后缀 | `StatusEnum`, `LangEnum` |
| 中间件类 | 大驼峰 + `Middleware` 后缀 | `AdminAuthMiddleware`, `OperateLogMiddleware` |
| 迁移文件 | `{version}_{module}_{table}` | `2024_01_01_000001_system_menu` |
| 数据库表 | `{prefix}_{module}_{table}` | `system_menu`, `member_user` |
| 数据库字段 | snake_case | `created_at`, `is_delete`, `parent_id` |
| 路由 code | {App}{Module}{Action} | `PlatformTenantList`, `SystemMenuUpdate` |
| 权限码 | `{module}:{model}:{action}` | `system:menu:list`, `member:user:create` |
| 事件名 | `{app}.{module}.{action}` | `adminapi.member.register`, `adminapi.menu.updated` |
| 前端组件 | 大驼峰 .vue | `MenuModal.vue`, `MemberForm.vue` |
| 前端Type接口 | 大驼峰 | `MenuRecord`, `MenuParam`, `MenuPageResult` |
| 前端API函数 | 小驼峰 | `getMenuList`, `createMenu`, `updateMenu` |
| 前端路由code | {App}{Module}{Action} | `SystemMenuList`, `PlatformTenantEdit` |
| 前端国际化key | `{module}.{model}.{field}` | `system.menu.name`, `member.user.mobile` |
| JSON响应字段 | snake_case | `items`, `total`, `page_no`, `page_size` |
| 目录/文件名 | kebab-case | `system/menu/index.vue`, `use-crud.ts` |

### Git 提交规范

```
<type>(<scope>): <subject>
```

| type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `refactor` | 重构 |
| `style` | UI 样式变更 |
| `perf` | 性能优化 |
| `chore` | 构建/工具/配置变更 |
| `docs` | 文档更新 |
| `test` | 测试相关 |
| `revert` | 回退 |

| scope | 说明 |
|-------|------|
| `admin` | Admin 前端 |
| `platform` | Platform 前端/后端 |
| `api` | API 端 |
| `install` | 安装模块 |
| `core` | Core 基础设施 |
| `server` | 服务端公共 |
| `plugin` | 插件 |
| `tenant` | 多租户 |

```
feat(admin): 新增会员积分管理页面
fix(api): 修复会员登录验证码校验失败问题
refactor(server): 重构菜单服务的查询逻辑
chore(core): 升级 webman 框架到 2.2
```

### 控制器继承链

```
AdminAPI: Controller → Crud → Base(BaseController)
Platform: Controller → Crud → Base(BaseController)
API:      Controller → Base(BaseController)
Install:  Controller → Base(BaseController)
```

### 推荐全局规则模板

```markdown
<tech_stack>
- 后端：PHP 8.2 + Workerman Webman 2.2 + Laravel Eloquent 11.33
- 前端：Vue 3 + TypeScript + Vben Admin 5.x（Monorepo: pnpm + Turborepo）
- 数据库：MySQL 8.0+（多租户库隔离）
- 实时通信：SSE（Server-Sent Events）
</tech_stack>

<coding_guidelines>
- 控制器继承 Crud 或 Base 基类，统一 Json::success() 返回
- 服务层注入 DAO，事务在 Service 层控制
- 模型使用雪花 ID + 软删除 + 多租户 Scope
- API 响应格式：{code, msg, data}，分页用 {items, total, page_no, page_size}
- 权限码格式：{module}:{model}:{action}
- 前端 CRUD 使用 useCrud composable + FormDialog 弹窗
</coding_guidelines>

<naming_conventions>
- PHP 类：大驼峰 + 后缀（Controller/Service/Dao/Validate）
- 数据库表：{prefix}_{module}_{table}
- 数据库字段：snake_case
- 前端 API 函数：小驼峰（getMenuList）
- JSON 响应字段：snake_case
</naming_conventions>
```
