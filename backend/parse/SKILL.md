---
name: madong-backend-parse
description: 表解析规范，用于代码生成器识别表结构
globs:
  - "core/**/parse/**/*.php"
---

## 文件位置

```
core/{module}/parse/{Module}Parse.php
```

## 字段标记

在数据库注释中使用 `{field}` 标记来标识特殊字段：

| 标记 | 说明 | 示例 |
|------|------|------|
| `snowflake` | 主键为雪花ID | `id` |
| `no-api` | 不暴露到API | `created_at`, `updated_at`, `deleted_at` |
| `public-create` | 创建时可编辑 | `name`, `code` |
| `image` | 图片字段 | `avatar`, `logo` |
| `editor` | 富文本编辑器 | `content`, `description` |

## 解析流程

```
1. 连接数据库 → 读取表结构
2. 提取字段名、类型、注释
3. 识别字段标记（snowflake/no-api/public-create/image/editor）
4. 生成模型/验证器/服务等代码模板
```

## 字段类型映射

| 数据库类型 | 代码生成对应的 PHP 类型 |
|-----------|----------------------|
| BIGINT | int (snowflake) |
| INT | int |
| TINYINT | int |
| VARCHAR | string |
| TEXT | string |
| DECIMAL | float |
| JSON | array |

## 关键约定

- 表注释中使用 `|{marker}|` 格式标记字段属性
- `no-api` 标记的字段不会出现在请求/响应 DTO 中
- `public-create` 标记的字段在创建接口中可见
- `image` 标记的字段会生成图片上传相关代码
- `editor` 标记的字段会生成富文本编辑器相关代码
- 解析结果直接供 `generator.SKILL.md` 中的生成命令使用

## 检查清单

- [ ] 表字段注释是否标注了必要的标记
- [ ] 主键是否标记了 `snowflake`
- [ ] 时间戳字段是否标记了 `no-api`
- [ ] 特殊类型字段（image/editor）是否标注了对应标记
