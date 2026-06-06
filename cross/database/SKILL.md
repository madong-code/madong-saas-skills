---
name: madong-cross-database
description: 数据库设计规范，表前缀/字段/索引/隔离
globs:
  - "app/**/database/migrations/**/*.php"
  - "*.sql"
---

## 表前缀分模块

| 前缀 | 模块 | 示例 |
|------|------|------|
| `system_` | 系统管理 | `system_menu`, `system_user`, `system_role` |
| `member_` | 会员管理 | `member_user`, `member_level`, `member_points_log` |
| `tenant_` | 租户管理 | `tenant_account`, `tenant_package` |
| `log_` | 日志 | `log_operation`, `log_login` |
| `dict_` | 字典 | `dict_type`, `dict_data` |
| `crontab_` | 定时任务 | `crontab_task`, `crontab_log` |

## 字段命名规范

| 规则 | 示例 |
|------|------|
| 全部小写 snake_case | `created_at`, `parent_id` |
| 主键统一 `id` | `id` |
| 外键 `{关联对象}_id` | `parent_id`, `user_id`, `role_id` |
| 时间戳 `{action}_at` | `created_at`, `updated_at`, `deleted_at` |
| 状态字段 `status`/`is_{property}` | `status`(一般状态), `is_delete`(标记删除) |
| 排序字段 `sort` | `sort` |

## 字段类型规范

| 类型 | 说明 |
|------|------|
| `BIGINT` (unsigned) | 主键、外键（雪花ID） |
| `INT` (unsigned) | 整数、排序、计数 |
| `TINYINT` | 状态、标志位（0/1） |
| `VARCHAR(N)` | 短字符串，N 根据实际需要 |
| `TEXT` | 长文本内容 |
| `DECIMAL(10,2)` | 金额、小数 |
| `JSON` | JSON 数据 |

## 索引规范

| 索引 | 规则 |
|------|------|
| 主键 | 每个表必须有主键（BIGINT unsigned） |
| 唯一索引 | 唯一约束字段加 unique |
| 普通索引 | 常用查询字段加 index |
| 联合索引 | 多字段查询条件建联合索引 |

## 软删除

- 使用 `deleted_at` 字段标记删除
- 类型：`BIGINT` (unsigned) default `0`
- 值为 0 表示未删除，非 0 表示删除时间戳
- Model 层使用 `SoftDeletes` trait

## 多租户隔离

- 字段隔离：表中加 `tenant_id` 字段
- 通过 `TenantScope` 全局作用域自动过滤
- 白名单模型不自动过滤（在 `config/tenant.php` 中配置）

## 检查清单

- [ ] 表前缀是否正确
- [ ] 字段名是否使用 snake_case
- [ ] 主键是否使用 BIGINT unsigned
- [ ] 是否有必要的索引
- [ ] 软删除是否实现
- [ ] 多租户表是否包含 `tenant_id` 字段
