---
name: madong-gen-service
description: Generate Service class. Only needs DAO injection in constructor. BaseService __call method auto-delegates to DAO.
---

# Service 生成规范

## 原则

**Service 只需注入 DAO，其他方法全部由 `BaseService::__call` 自动代理到 DAO！**

```php
class {Model}Service extends BaseService
{
    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }
}
```

`BaseService::__call()` 会自动将所有方法调用转发给 `$this->dao`。

## 文件位置

**App:**
```
app/service/admin/{module}/{Model}Service.php
```

**Plugin:**
```
plugin/{Plugin}/app/service/admin/{module}/{Model}Service.php
```

## Service 模板

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

namespace {ns}\service\admin\{module};

use {dao_ns}\{module}\{Model}Dao;
use core\base\BaseService;

/**
 * {Model}服务层
 */
class {Model}Service extends BaseService
{
    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }
}
```

## 只有需要特殊业务逻辑时才加方法

```php
class {Model}Service extends BaseService
{
    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }

    // 只有特殊业务逻辑才定义方法
    // 普通 CRUD 直接通过 __call 代理到 DAO
}
```

### 业务逻辑示例

```php
/**
 * 批量操作示例
 */
public function batchAssign(array $ids, int $categoryId): void
{
    $this->transaction(function () use ($ids, $categoryId) {
        foreach ($ids as $id) {
            $item = $this->dao->get($id);
            if ($item) {
                $item->category_id = $categoryId;
                $item->save();
            }
        }
    });
}
```

## 调用示例

```php
// Service 实例化后直接调用，__call 自动代理到 DAO
$service = new {Model}Service(new {Model}Dao());
$list = $service->selectList($where, '*', $page, $limit);  // 代理到 DAO
$item = $service->get($id);                                 // 代理到 DAO
$count = $service->count($where);                          // 代理到 DAO
$service->save($data);                                     // 代理到 DAO
```

## BaseService 提供的方法

| 方法 | 说明 |
|------|------|
| `transaction(callable)` | 事务执行 |
| `cacheDriver()` | 获取缓存服务 |
| `getPageValue()` | 获取分页配置 |
| `passwordHash()` | 密码加密 |
| `__call()` | 自动代理到 DAO |

## 生成检查清单

- [ ] 命名空间正确（App/Plugin）
- [ ] 引入 BaseService
- [ ] 引入 DAO 类
- [ ] 构造函数注入 DAO
- [ ] 只有特殊业务逻辑才加方法
