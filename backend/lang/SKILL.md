---
name: madong-backend-lang
description: 后端国际化规范，PHP嵌套数组结构
globs:
  - "resource/lang/**/*.php"
---

## 文件位置

```
resource/lang/{locale}/{module}.php
```

| 语言 | locale | 路径 |
|------|--------|------|
| 简体中文 | `zh_CN` | `resource/lang/zh_CN/{module}.php` |
| English | `en` | `resource/lang/en/{module}.php` |

## 文件结构

```php
<?php

return [
    '{module}' => [
        '{model}' => [
            '{field}' => '{翻译文本}',
        ],
    ],
];
```

### 示例

```php
<?php
// resource/lang/zh_CN/system.php

return [
    'menu' => [
        'name'        => '菜单名称',
        'pid'         => '上级菜单',
        'code'        => '菜单标识',
        'icon'        => '图标',
        'sort'        => '排序',
        'status'      => '状态',
    ],
    'role' => [
        'name'        => '角色名称',
        'code'        => '角色标识',
        'status'      => '状态',
    ],
];
```

## 获取翻译

```php
// 使用 webman 的 translation 组件
trans('system.menu.name');        // 菜单名称
trans('system.menu.status');      // 状态

// 指定语言
trans('system.menu.name', [], 'en');  // Menu Name
```

## 关键约定

- key 命名格式：`{module}.{model}.{field}`（模块.模型.字段）
- 英文文件 key 不变，只改 value
- 每个模块一个独立文件（如 `system.php` / `member.php`）
- 翻译文本必须包含中文，即使是英文字段也要写
- 验证器错误消息使用独立的 `$messages` 属性而非 lang 文件
- 前端国际化使用 `frontend/apps/{app}/src/locales/langs/` 下的 JSON 文件

## 检查清单

- [ ] key 格式是否为 `{module}.{model}.{field}`
- [ ] zh_CN 和 en 两个文件是否都创建了
- [ ] 英文文件是否修改了 value 而非 key
