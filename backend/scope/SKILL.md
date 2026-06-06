---
name: madong-backend-scope
description: 数据权限作用域规范，TenantScope/DataPermissionScope
globs:
  - "app/**/scope/**/*.php"
---

## 文件位置

```
app/scope/
├── global/
│   ├── TenantScope.php              # 多租户数据隔离
│   └── AccessPermissionScope.php    # 数据权限过滤
└── DataPermissionScope.php          # 数据权限基础类
```

## 各作用域说明

### TenantScope（多租户隔离）

作用：自动为租户下的所有查询添加 `tenant_id` 过滤条件。

```php
class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        // 自动添加 tenant_id = {当前租户ID}
        if (TenantContext::has()) {
            $builder->where('tenant_id', TenantContext::get()->id);
        }
    }
}
```

### AccessPermissionScope（数据权限）

作用：根据用户角色过滤可见数据。

```php
class AccessPermissionScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        // 只有数据权限范围内的数据才会被查询
        // 根据当前用户所属角色/部门的权限范围过滤
    }
}
```

## 使用方式

```php
// 全局作用域（在 BaseModel 或特定模型中注册）
protected static function booted(): void
{
    static::addGlobalScope(new TenantScope());
    static::addGlobalScope(new AccessPermissionScope());
}

// 临时取消作用域
Model::withoutGlobalScope(TenantScope::class)->get();

// 临时取消所有全局作用域
Model::withoutGlobalScopes()->get();
```

## 关键约定

- 全局作用域在 `BaseModel` 中注册，所有模型默认继承
- 需要跳过租户过滤的模型在 `config/tenant.php` 的白名单中配置
- 取消作用域使用 `withoutGlobalScope()` / `withoutGlobalScopes()`
- 数据权限作用域仅影响列表查询（index），不影响详情（show）和写入操作

## 检查清单

- [ ] 租户模型是否注册了 `TenantScope`
- [ ] 不需要租户过滤的模型是否加入了白名单
- [ ] 需要使用 `withoutGlobalScope` 的场景是否已正确处理
