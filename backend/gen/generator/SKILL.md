---
name: madong-gen-generator
description: 代码生成器规范，Gen命令 + Stub模板
globs:
  - "app/**/command/stubs/**/*"
---

## 文件位置

```
app/command/
├── stubs/                    # 代码模板目录
│   ├── controller.stub
│   ├── service.stub
│   ├── dao.stub
│   ├── model.stub
│   └── validate.stub
├── ControllerCommand.php     # 控制器生成命令
├── DaoCommand.php            # DAO生成命令
├── ModelCommand.php          # 模型生成命令
├── ServiceCommand.php        # 服务生成命令
└── ValidateCommand.php       # 验证器生成命令
```

## 生成命令

| 命令 | 入口 | 说明 |
|------|------|------|
| `gen:controller` | `php webman gen:controller {module} {name}` | 生成控制器 |
| `gen:service` | `php webman gen:service {module} {name}` | 生成服务 |
| `gen:dao` | `php webman gen:dao {module} {name}` | 生成 DAO |
| `gen:model` | `php webman gen:model {module} {name}` | 生成模型 |
| `gen:validate` | `php webman gen:validate {module} {name}` | 生成验证器 |
| `gen:middleware` | `php webman gen:middleware {name}` | 生成中间件 |

## 生成流程

```
1. 解析表结构（parse）
2. 获取字段列表和类型
3. 替换 Stub 模板中的变量
4. 写入目标文件
```

## 模板变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `{namespace}` | 命名空间 | `app\adminapi\controller\system` |
| `{class_name}` | 类名 | `MenuController` |
| `{model_name}` | 模型名 | `Menu` |
| `{model_var}` | 模型变量名 | `menu` |
| `{dao_name}` | DAO名 | `MenuDao` |
| `{service_name}` | 服务名 | `MenuService` |
| `{validate_name}` | 验证器名 | `MenuValidate` |
| `{table_name}` | 表名 | `system_menu` |
| `{fields}` | 字段列表 | 自动生成 |

## 关键约定

- 生成命令支持 `app`（主项目）和 `plugin`（插件）两种模式
- 插件模式下命名空间自动切换为 `addon\{plugin_name}\`
- Stub 模板使用 `.stub` 后缀，放在 `app/command/stubs/` 目录
- 生成代码后需要手动注册路由或补充 Swagger 注解
- 代码生成不覆盖已存在的文件（新增模式）
- 使用 `parse` 命令解析表结构后，其他生成命令可以直接使用解析结果

## 检查清单

- [ ] 生成命令是否传了正确的模块和名称参数
- [ ] 是 app 模式还是 plugin 模式
- [ ] 生成后是否需要手动注册路由
- [ ] 是否需要补充 Swagger 注解
