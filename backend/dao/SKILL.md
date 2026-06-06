---
name: madong-backend-dao
description: 数据访问层规范，继承 BaseDao，定义 setModel
globs:
  - "app/**/dao/**/*.php"
---

## 文件位置

| 端 | 路径 |
|----|------|
| Admin/共享 | `app/dao/{module}/{Model}Dao.php` |

DAO 层是跨端共享的，admin/platform/api 使用同一个 DAO。

## 基类说明

### BaseDao (`core\foundation\base\BaseDao`)

必须实现的方法：

```php
abstract protected function setModel(): string; // 返回模型类名
```

### 完整方法列表

| 方法 | 说明 |
|------|------|
| `selectList(array $where, string $field='*', int $page=0, int $limit=0, string $order='', array $with=[], bool $search=false)` | 分页列表 |
| `get($id, ?array $field=null, ?array $with=[], string $order='')` | 主键查询 |
| `getOne(array $where, ?string $field='*', array $with=[])` | 单条查询 |
| `save(array $data)` | 新增 |
| `update(string|int|array $id, array $data)` | 更新 |
| `delete(array|int|string $id)` | 删除（软删除时进入回收站） |
| `destroy(mixed $id, bool $force=false)` | 真实删除 |
| `count(array $where=[], bool $search=true)` | 计数 |
| `sum(array $where, string $field, bool $search=false)` | 求和 |
| `search(array $where=[], bool $search=true)` | 查询构建器 |
| `value($where, ?string $field='')` | 获取单个值 |
| `getColumn(array $where, string $field, string $key='')` | 获取一列 |
| `batchUpdate(array $ids, array $data)` | 批量更新 |
| `saveAll(array $data)` | 批量新增 |
| `setWhere($where, ?string $key=null)` | 设置 where 条件 |
| `getPk()` | 获取主键名 |
| `getTableName()` | 获取表名 |
| `transaction(Closure $callback)` | 事务 |

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\dao\{module};

use app\model\{module}\{Model};
use core\foundation\base\BaseDao;

class {Model}Dao extends BaseDao
{
    protected function setModel(): string
    {
        return {Model}::class;
    }

    // 仅在需要特殊查询时重写，普通 CRUD 不需要额外方法
    public function getListWithSomething(array $where): array
    {
        return $this->search($where)->with(['relation'])->get()->toArray();
    }
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | system/member/content/ops/tenant 等 |
| `{Model}` | Menu/Member/Article/Config 等 |

## 关键约定

- `setModel()` 必须返回完整模型类名（含命名空间）
- DAO 方法调用时 where 条件使用系统统一格式，如 `['field', '=', 'value']` 或 `['field', 'value']`
- DAO 不处理业务逻辑，只负责数据访问
- DAO 可以被多个 Service 复用
- 事务操作在 Service 层使用 `$this->dao->transaction()` 或 `$this->dao->getModel()->getConnection()->transaction()`

## 检查清单

- [ ] `setModel()` 是否正确返回模型类名
- [ ] 命名空间是否正确（`app\dao\{module}`）
- [ ] 是否只包含数据访问逻辑，无业务逻辑
- [ ] 复杂查询如果不需要复用，是否可以直接在 Service 中通过 `__call` 使用
