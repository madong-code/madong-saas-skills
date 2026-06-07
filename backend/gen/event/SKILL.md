---
name: madong-gen-event
description: 事件生成规范
---

# 事件 (Event) 生成规范

## 目录结构

```
{module}/event/
└── {Name}Event.php          # 事件类文件

# {module}: adminapi / api / plugin\{Plugin}\app\adminapi
# {Name}: 事件名称，如 LoginLog, PointsChanged
```

## 事件命名规范

| 场景 | 命名示例 | 触发事件名 |
|------|----------|------------|
| 登录日志 | `LoginLogEvent` | `adminapi.login.log` |
| 操作日志 | `OperationLogEvent` | `adminapi.operation.log` |
| 积分变动 | `PointsChangedEvent` | `adminapi.points.changed` |
| 会员等级更新 | `MemberLevelUpdatedEvent` | `adminapi.member.level.updated` |
| 审核状态 | `ReviewApprovedEvent` | `adminapi.review.approved` |

## 事件触发事件名规范

- 格式：`{app}.{module}.{action}`
- AdminAPI: `adminapi.{module}.{action}`
- API: `member.{module}.{action}`

## 事件类模板

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

namespace {namespace};

use Webman\Event\Event;

/**
 * {事件描述}
 */
class {Name}Event
{
    /**
     * 会员ID
     */
    public int|string $memberId;
    
    /**
     * 变动前积分
     */
    public int $oldPoints;
    
    /**
     * 变动后积分
     */
    public int $newPoints;
    
    /**
     * 变动的积分数量
     */
    public int $points;
    
    /**
     * 变动类型（增加/减少）
     */
    public {EnumClass} $type;
    
    /**
     * 变动原因/备注
     */
    public string $remark;
    
    /**
     * 关联ID（如订单ID、活动ID等，可选）
     */
    public int|string|null $relatedId;
    
    /**
     * 额外数据（可选）
     */
    public ?array $extra;
    
    /**
     * 构造函数
     */
    public function __construct(
        int|string $memberId,
        int $points,
        {EnumClass} $type,
        int $oldPoints,
        int $newPoints,
        string $remark = '',
        int|string|null $relatedId = null,
        ?array $extra = null
    ) {
        $this->memberId = $memberId;
        $this->points = $points;
        $this->type = $type;
        $this->oldPoints = $oldPoints;
        $this->newPoints = $newPoints;
        $this->remark = $remark;
        $this->relatedId = $relatedId;
        $this->extra = $extra;
    }

    /**
     * 触发事件
     */
    public function dispatch(): void
    {
        Event::emit('{app}.{module}.{action}', $this);
    }
}
```

## 属性类型说明

| 类型 | 说明 |
|------|------|
| `int\|string` | ID 类字段 |
| `int` | 数量、状态码 |
| `string` | 名称、备注 |
| `array` | 扩展数据 |
| `{EnumClass}` | 枚举类型（推荐使用） |
| `?array` | 可选数组 |

## 事件触发方式

### 方式一：事件内部触发（推荐）

```php
// 在事件类中
public function dispatch(): void
{
    Event::emit('adminapi.points.changed', $this);
}

// 调用时
$event = new PointsChangedEvent(...);
$event->dispatch();
```

### 方式二：直接触发

```php
Event::emit('adminapi.points.changed', new PointsChangedEvent(...));
```

## 可修改的事件（用于扩展）

如果事件需要在监听器中修改数据，使用引用属性：

```php
class MemberInfoFetchedEvent
{
    public int $memberId;
    public array $userData = [];       // 可修改
    public array $permissions = [];    // 可追加
    public array $extra = [];          // 可追加
    
    // 添加权限方法
    public function addPermission(string $permission): void
    {
        if (!in_array($permission, $this->permissions)) {
            $this->permissions[] = $permission;
        }
    }
    
    // 添加额外字段
    public function addExtra(string $key, mixed $value): void
    {
        $this->extra[$key] = $value;
    }
}
```

## 路径变量

| 变量 | App | Plugin |
|------|-----|--------|
| `{namespace}` | `app\adminapi\event` | `plugin\{Plugin}\app\adminapi\event` |
| `{app}` | `adminapi` / `api` | `adminapi` / `api` |
| `{module}` | 业务模块 | 业务模块 |
| `{action}` | 操作名称 | 操作名称 |

## 生成示例

### 积分变动事件

```
模块: adminapi
事件名: PointsChangedEvent
```

生成文件: `app/adminapi/event/PointsChangedEvent.php`

### 登录日志事件

```
模块: adminapi
事件名: LoginLogEvent
```

生成文件: `app/adminapi/event/LoginLogEvent.php`
