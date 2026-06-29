---
name: madong-gen-dao
description: Generate DAO class. Only needs setModel() and optional getKeywordFields(). BaseDao provides all CRUD methods.
---

# DAO 生成规范

## 原则

**DAO 只需定义 `setModel()`，其他方法全部使用 BaseDao 基类！**

BaseDao 提供的方法：
- `selectList()` - 分页查询
- `get()` / `getOne()` - 获取单条
- `save()` / `saveAll()` - 创建/批量创建
- `update()` / `batchUpdate()` - 更新/批量更新
- `delete()` / `destroy()` - 删除
- `count()` / `getCount()` - 计数
- `value()` / `getColumn()` - 获取字段值
- `search()` - 搜索
- `sum()` / `getMax()` / `getMin()` - 统计
- `transaction()` - 事务

## 文件位置

**App:**
```
app/dao/{module}/{Model}Dao.php
```

**Plugin:**
```
plugin/{Plugin}/app/dao/{module}/{Model}Dao.php
```

## DAO 模板

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

namespace {ns}\dao\{module};

use {model_ns}\{module}\{Model};
use core\foundation\base\BaseDao;

/**
 * {Model}数据访问层
 */
class {Model}Dao extends BaseDao
{
    protected function setModel(): string
    {
        return {Model}::class;
    }
}
```

## 可选配置

### 关键词搜索字段

```php
protected function getKeywordFields(): array
{
    return ['name', 'title'];
}
```

## 调用示例

```php
// 注入 Service 后，Service 通过 __call 自动代理到 DAO
$list = $this->dao->selectList($where, '*', $page, $limit);
$item = $this->dao->get($id);
$count = $this->dao->count($where);
$this->dao->save($data);
$this->dao->update($id, $data);
$this->dao->delete($id);
```

## 生成检查清单

- [ ] 命名空间正确（App/Plugin）
- [ ] 引入 BaseDao
- [ ] 引入 Model 类
- [ ] 实现 `setModel()` 返回模型类名
- [ ] 可选：定义 `getKeywordFields()` 搜索字段
