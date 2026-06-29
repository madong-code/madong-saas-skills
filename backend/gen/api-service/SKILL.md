---
name: madong-gen-api-service
description: Generate API service class for madong module (前台 API 服务层). Supports both app (main project) and plugin targets. Creates service extending BaseService with DAO injection and custom business methods.
---

# Generate API Service (前台 API 服务层)

Create service class for module (前台 API 访问).

> **注意**: 基于 portal 插件实际实现，API 服务层使用自定义业务方法（非通用 CRUD 代理），通过 `Container::make(CurrentMember::class)` 获取当前会员信息。

## File Location

**App (主项目):**
```
app/api/service/{module}/{Model}Service.php
```

**Plugin (插件):**
```
plugin/{plugin}/app/api/service/{module}/{Model}Service.php
```

## Target Variables

| 变量 | App | Plugin |
|------|-----|--------|
| `{prefix}` | `` (空) | `plugin\{Plugin}` |
| `{ns}` | `app` | `plugin\{Plugin}\app` |
| `{dao_ns}` | `app\dao` | `plugin\{Plugin}\app\dao` |
| `{model_ns}` | `app\model` | `plugin\{Plugin}\app\model` |

## API Service Features

- **继承 BaseService**: 继承 `core\foundation\base\BaseService`
- **自定义方法**: 使用 `getList()`、`create()`、`detail()`、`update()`、`delete()` 等业务方法
- **会员获取**: 通过 `Container::make(CurrentMember::class)->id()` 获取当前会员
- **事务支持**: 使用 `$this->transaction()` 执行事务操作
- **事件触发**: 可在业务方法中派发事件

## API Service Template

```php
<?php

declare(strict_types=1);
/**
 *+------------------
 * madong
 *+------------------
 * Copyright (c) https://gitee.com/motion-code  All rights reserved.
 *+------------------
 * Author: Mr. April (405784684@qq.com)
 *+------------------
 * Official Website: http://www.madong.tech
 */

namespace {ns}\api\service\{module};

use app\api\CurrentMember;
use {dao_ns}\{module}\{Model}Dao;
use {model_ns}\{module}\{Model};
use core\foundation\base\BaseService;
use support\Container;

/**
 * {Model}前台API服务类
 */
class {Model}Service extends BaseService
{
    public function __construct({Model}Dao $dao)
    {
        $this->dao = $dao;
    }

    /**
     * 获取列表
     */
    public function getList(array $params): array
    {
        // 自定义查询逻辑
        return $this->dao->getList($params);
    }

    /**
     * 获取详情
     */
    public function detail(string $id): array
    {
        return $this->dao->detail($id);
    }

    /**
     * 创建
     */
    public function create(array $data): array
    {
        return $this->transaction(function () use ($data) {
            $model = $this->save($data);
            // 业务逻辑：关联数据、触发事件等
            return $model->load(['relation'])->toArray();
        });
    }

    /**
     * 更新
     */
    public function update(string $id, array $data): array
    {
        return $this->transaction(function () use ($id, $data) {
            $model = $this->dao->update($id, $data);
            return $model->toArray();
        });
    }

    /**
     * 删除
     */
    public function delete(string $id): bool
    {
        // 检查数据归属
        $memberId = $this->getCurrentMemberId();
        return $this->dao->deleteByUser($id, $memberId);
    }

    /**
     * 获取当前会员ID
     */
    protected function getCurrentMemberId(): ?int
    {
        try {
            return Container::make(CurrentMember::class)->id();
        } catch (\Exception $e) {
            throw new \Exception('请先登录');
        }
    }
}
```

## Complete Example (Plugin - 基于 portal 实际实现)

```php
<?php

declare(strict_types=1);
/**
 *+------------------
 * madong
 *+------------------
 * Copyright (c) https://gitee.com/motion-code  All rights reserved.
 *+------------------
 * Author: Mr. April (405784684@qq.com)
 *+------------------
 * Official Website: http://www.madong.tech
 */

namespace plugin\portal\app\api\service\question;

use app\api\CurrentMember;
use plugin\portal\app\event\QuestionCreatedEvent;
use plugin\portal\app\event\QuestionUpdatedEvent;
use core\foundation\base\BaseService;
use plugin\portal\app\dao\question\QuestionDao;
use plugin\portal\app\model\question\Question;
use support\Container;
use Exception;

class QuestionService extends BaseService
{
    public function __construct(
        QuestionDao $dao,
        private readonly TagService $tagService
    )
    {
        $this->dao = $dao;
    }

    public function getList(array $args): array
    {
        return $this->dao->getList($args);
    }

    public function detail(int $id): array
    {
        $question = $this->dao->getDetail($id);
        // 格式化数据...
        return $formattedData ?? [];
    }

    public function create(array $data): array
    {
        $memberId = Container::make(CurrentMember::class)->id();
        return $this->transaction(function () use ($memberId, $data) {
            $question = $this->save($data);
            $question->tags()->sync($data['tags'] ?? []);
            $event = new QuestionCreatedEvent($question);
            $event->dispatch();
            return $question->load(['tags', 'member'])->toArray();
        });
    }

    public function update(string $id, array $data): array
    {
        return $this->transaction(function () use ($id, $data) {
            // 检查会员归属
            $question = Question::where('id', $id)
                ->where('member_id', $memberId)
                ->first();
            // 更新逻辑...
        });
    }

    public function delete(string $id): bool
    {
        $userId = Container::make(CurrentMember::class)->id();
        return $this->dao->deleteByUser($id, $userId);
    }
}
```

## Service Methods

### CRUD Operations

| Method | Description |
|--------|-------------|
| `getList()` | Get paginated list with custom query |
| `detail()` | Get detail with formatted data |
| `create()` | Create new record (with transaction) |
| `update()` | Update existing record (with ownership check) |
| `delete()` | Delete record (with ownership check) |

### DAO Methods (via __call)

| Method | Description |
|--------|-------------|
| `save()` | Save record (delegated to DAO) |
| `count()` | Count records |
| `selectList()` | Select paginated list |

## Auto-generation Checklist

When generating API service:
- [ ] Set correct namespace `{ns}\api\service\{module}`
- [ ] Import `core\foundation\base\BaseService`
- [ ] Import DAO and Model classes
- [ ] Inject DAO in constructor
- [ ] Import `CurrentMember` via `Container::make()`
- [ ] Implement custom business methods (not generic CRUD)
- [ ] Add transaction support for complex operations
- [ ] Add ownership check for update/delete
