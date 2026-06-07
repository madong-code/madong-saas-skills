---
name: madong-gen-api-service
description: Generate API service class for madong module前台API服务层. Supports both app (main project) and plugin targets. Creates service extending BaseService with DAO injection and standard CRUD operations for public/member access.
---

# Generate API Service (前台 API 服务层)

Create service class for module (前台 API 访问).

## File Location

**App (主项目):**
```
app/service/api/{module}/{Model}Service.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/service/api/{module}/{Model}Service.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{dao_ns}` | `app\dao` | `plugin\{Plugin}\app\dao` |
| `{model_ns}` | `app\model` | `plugin\{Plugin}\app\model` |

## API Service Features

- **继承 BaseService**: 继承 `core\base\BaseService`
- **轻量级操作**: 不触发事件，适合公开访问
- **雪花ID**: 支持雪花ID作为主键
- **会员关联**: 支持与会员关联的数据操作

## API Service Template

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

namespace {ns}\service\api\{module};

use {dao_ns}\{module}\{Model}Dao;
use {model_ns}\{module}\{Model};
use core\base\BaseService;

/**
 * {Model}前台API服务类
 *
 * Class {Model}Service
 */
class {Model}Service extends BaseService
{
    /**
     * 注入{Model}Dao
     *
     * @param {Model}Dao $dao
     */
    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }

    /**
     * 获取{Model}Dao
     *
     * @return {Model}Dao
     */
    public function getDao(): {Model}Dao
    {
        return $this->dao;
    }

    /**
     * 获取列表
     *
     * @param array $where 查询条件
     * @param string $field 查询字段
     * @param int $page 页码
     * @param int $limit 每页数量
     * @param string $order 排序
     * @return array
     */
    public function selectList(array $where = [], string $field = '*', int $page = 1, int $limit = 20, string $order = 'id desc'): array
    {
        $list = $this->dao->selectList($where, $field, $page, $limit, $order);
        return {Model}::formatList($list);
    }

    /**
     * 获取总数
     *
     * @param array $where 查询条件
     * @return int
     */
    public function count(array $where = []): int
    {
        return $this->dao->count($where);
    }

    /**
     * 获取详情
     *
     * @param int $id
     * @param array $field
     * @return array
     */
    public function get(int $id, array $field = ['*']): array
    {
        $data = $this->dao->findOrFail($id, $field);
        return {Model}::formatDetail($data);
    }

    /**
     * 创建
     *
     * @param array $data
     * @return {Model}
     */
    public function save(array $data): {Model}
    {
        // 如果需要关联会员，自动设置会员ID
        if ($this->hasMemberField() && isset($this->memberId)) {
            $memberField = $this->getMemberField();
            if ($memberField && !isset($data[$memberField])) {
                $data[$memberField] = $this->memberId;
            }
        }

        return $this->dao->create($data);
    }

    /**
     * 更新
     *
     * @param int $id
     * @param array $data
     * @return bool
     */
    public function update(int $id, array $data): bool
    {
        // 检查是否为会员自己的数据
        if ($this->hasMemberField()) {
            $memberField = $this->getMemberField();
            $record = $this->dao->findWhere([$memberField => $this->memberId, 'id' => $id]);
            if (!$record) {
                throw new \Exception('无权修改此数据');
            }
        }

        return $this->dao->update($id, $data);
    }

    /**
     * 删除
     *
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool
    {
        // 检查是否为会员自己的数据
        if ($this->hasMemberField()) {
            $memberField = $this->getMemberField();
            $record = $this->dao->findWhere([$memberField => $this->memberId, 'id' => $id]);
            if (!$record) {
                throw new \Exception('无权删除此数据');
            }
        }

        return $this->dao->delete($id);
    }

    /**
     * 获取会员ID
     *
     * @return int|null
     */
    protected function getMemberId(): ?int
    {
        try {
            $currentMember = \app\api\CurrentMember::create();
            return $currentMember->id();
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * 检查是否有会员关联字段
     *
     * @return bool
     */
    protected function hasMemberField(): bool
    {
        return in_array('member_id', (new {Model}())->getFillable());
    }

    /**
     * 获取会员关联字段名
     *
     * @return string|null
     */
    protected function getMemberField(): ?string
    {
        return $this->hasMemberField() ? 'member_id' : null;
    }
}
```

## Complete Example (App)

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

namespace app\service\api\question;

use app\dao\question\QuestionDao;
use app\model\question\Question;
use core\base\BaseService;

/**
 * 问题前台API服务类
 *
 * Class QuestionService
 */
class QuestionService extends BaseService
{
    public function __construct(QuestionDao $dao)
    {
        $this->dao = $dao;
    }

    public function selectList(array $where = [], string $field = '*', int $page = 1, int $limit = 20, string $order = 'id desc'): array
    {
        $list = $this->dao->selectList($where, $field, $page, $limit, $order);
        return Question::formatList($list);
    }

    public function count(array $where = []): int
    {
        return $this->dao->count($where);
    }

    public function get(int $id, array $field = ['*']): array
    {
        $data = $this->dao->findOrFail($id, $field);
        return Question::formatDetail($data);
    }

    public function save(array $data): Question
    {
        if (isset($this->memberId)) {
            $data['member_id'] = $this->memberId;
        }
        return $this->dao->create($data);
    }

    public function update(int $id, array $data): bool
    {
        $record = $this->dao->findWhere(['member_id' => $this->memberId, 'id' => $id]);
        if (!$record) {
            throw new \Exception('无权修改此问题');
        }
        return $this->dao->update($id, $data);
    }

    public function delete(int $id): bool
    {
        $record = $this->dao->findWhere(['member_id' => $this->memberId, 'id' => $id]);
        if (!$record) {
            throw new \Exception('无权删除此问题');
        }
        return $this->dao->delete($id);
    }

    protected function getMemberId(): ?int
    {
        try {
            return \app\api\CurrentMember::create()->id();
        } catch (\Exception $e) {
            return null;
        }
    }
}
```

## Complete Example (Plugin)

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

namespace plugin\official\app\service\api\question;

use plugin\official\app\dao\question\QuestionDao;
use plugin\official\app\model\question\Question;
use core\base\BaseService;

/**
 * 问题前台API服务类
 *
 * Class QuestionService
 */
class QuestionService extends BaseService
{
    public function __construct(QuestionDao $dao)
    {
        $this->dao = $dao;
    }

    // ... 方法同上
}
```

## Service Methods

### CRUD Operations

| Method | Description |
|--------|-------------|
| `selectList()` | Get paginated list |
| `count()` | Get total count |
| `get()` | Get single record |
| `save()` | Create new record (with member_id if applicable) |
| `update()` | Update existing record (with ownership check) |
| `delete()` | Delete record (with ownership check) |

### Member Support Methods

| Method | Description |
|--------|-------------|
| `getMemberId()` | Get current member ID |
| `hasMemberField()` | Check if model has member_id field |
| `getMemberField()` | Get member field name |

## Auto-generation Checklist

When generating API service:
- [ ] Set correct namespace based on target
- [ ] Import BaseService
- [ ] Import DAO
- [ ] Import Model class
- [ ] Inject DAO in constructor
- [ ] Implement standard CRUD methods
- [ ] Add member ownership check for update/delete
- [ ] Add getMemberId() helper method
