---
name: madong-backend-bootstrap
description: 启动引导层规范，CoreConfig/MorphMap/ValidationRules
globs:
  - "app/**/bootstrap/**/*.php"
---

## 文件位置

```
app/bootstrap/
├── CoreConfigBootstrap.php           # Core 模块配置加载
├── MorphMapBootstrap.php             # 多态关联映射注册
└── ValidationRulesBootstrap.php      # 自定义验证规则注册
```

## 各 Bootstrap 说明

### CoreConfigBootstrap

```php
class CoreConfigBootstrap
{
    // 扫描 core/ 目录下所有启用的模块
    // 加载其 config/ 目录中的配置到 Config::set('core.{module}.*')
    // 模块启用状态在 config/app.php 的 enable 字段控制
}
```

### MorphMapBootstrap

```php
class MorphMapBootstrap
{
    // 收集主项目 config('morph_map.map') 配置
    // 扫描 plugin/ 目录下每个插件的 config/morph_map.php
    // 合并后调用 Relation::enforceMorphMap() 注册
    // CLI 环境需要手动调用 forceLoad()
}
```

### ValidationRulesBootstrap

```php
class ValidationRulesBootstrap
{
    // 注册自定义验证规则
    // mobile / phone: 验证中国大陆手机号 ^1[3-9]\d{9}$
}
```

## 注册方式

Bootstrap 类在 `config/bootstrap.php` 中配置：

```php
return [
    app\bootstrap\CoreConfigBootstrap::class,
    app\bootstrap\MorphMapBootstrap::class,
    app\bootstrap\ValidationRulesBootstrap::class,
];
```

执行时机：`support/bootstrap.php` → 依次执行所有注册的 Bootstrap。

## 关键约定

- 所有 Bootstrap 放在 `app/bootstrap/` 目录
- 在 `config/bootstrap.php` 中注册（按执行顺序排列）
- Bootstrap 在应用启动时执行一次，不能有循环依赖
- CoreConfigBootstrap 先执行，确保配置可用后再执行其他 Bootstrap
- MorphMapBootstrap 在非 CLI 环境自动执行，CLI 需手动调用 forceLoad()

## 检查清单

- [ ] 新 Bootstrap 是否已注册到 `config/bootstrap.php`
- [ ] Bootstrap 执行顺序是否合理（CoreConfig → MorphMap → ValidationRules）
