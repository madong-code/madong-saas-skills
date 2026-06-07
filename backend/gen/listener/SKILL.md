---
name: madong-gen-listener
description: 监听器生成规范
---

# 监听器 (Listener) 生成规范

## 目录结构

```
{module}/listener/
└── {Name}Listener.php        # 监听器类文件

# {module}: adminapi / api
# {Name}: 监听名称，如 LoginLog, PointsChanged
```

## 监听器命名规范

| 事件 | 监听器 | 触发事件名 |
|------|--------|------------|
| `LoginLogEvent` | `LoginLogListener` | `adminapi.login.log` |
| `OperationLogEvent` | `OperationLogListener` | `adminapi.operation.log` |
| `PointsChangedEvent` | `PointsChangedListener` | `adminapi.points.changed` |
| `MemberLevelUpdatedEvent` | `MemberLevelUpdatedListener` | `adminapi.member.level.updated` |
| `ReviewApprovedEvent` | `ReviewApprovedListener` | `adminapi.review.approved` |

## 监听器模板

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

use app\adminapi\event\{Name}Event;
use app\dao\{domain}\{Name}Dao;
use support\Container;

/**
 * {监听描述}
 */
class {Name}Listener
{
    /**
     * 处理{事件名}事件
     *
     * @param {Name}Event $event
     * @return void
     * @throws \Exception
     */
    public function handle({Name}Event $event): void
    {
        // 业务逻辑处理
        $this->process($event);
    }
    
    /**
     * 处理业务逻辑
     *
     * @param {Name}Event $event
     * @return void
     * @throws \Exception
     */
    private function process({Name}Event $event): void
    {
        /** @var {Name}Dao $dao */
        $dao = Container::make({Name}Dao::class);
        
        $dao->save([
            'field1' => $event->field1,
            'field2' => $event->field2,
            // ...
        ]);
    }
}
```

## DAO 调用方式

使用 `Container::make()` 获取 DAO 实例：

```php
/** @var LoginLogDao $dao */
$dao = Container::make(LoginLogDao::class);
$dao->save([...]);
```

## 监听器注册

监听器需要在 `config/event.php` 中注册：

```php
return [
    // 事件名 => [[监听器类, 方法名], ...]
    'adminapi.login.log' => [
        [\app\adminapi\listener\LoginLogListener::class, 'handle'],
    ],
    
    // 支持多个监听器
    'adminapi.points.changed' => [
        [\app\adminapi\listener\PointsChangedListener::class, 'handle'],
        // 可以添加更多监听器
    ],
];
```

## 复杂监听器示例

处理积分变动并触发其他事件：

```php
<?php
declare(strict_types=1);

namespace app\adminapi\listener;

use app\adminapi\event\PointsChangedEvent;
use app\adminapi\event\MemberLevelUpdatedEvent;
use app\dao\member\MemberDao;
use app\dao\member\MemberLevelDao;
use app\dao\member\MemberPointsDao;
use app\enum\member\PointType;
use support\Container;

/**
 * 积分变动监听器
 * 
 * 处理积分变动的事件：
 * 1. 更新会员积分
 * 2. 记录积分流水
 * 3. 触发会员等级更新事件
 */
class PointsChangedListener
{
    /**
     * 处理积分变动事件
     */
    public function handle(PointsChangedEvent $event): void
    {
        // 更新会员积分
        $this->updateMemberPoints($event);
        
        // 记录积分流水
        $this->recordPointsLog($event);
        
        // 触发会员等级更新事件
        $this->updateMemberLevel($event);
    }
    
    /**
     * 更新会员积分
     */
    private function updateMemberPoints(PointsChangedEvent $event): void
    {
        /** @var MemberDao $dao */
        $dao = Container::make(MemberDao::class);
        $member = $dao->get($event->memberId);
        
        if (!$member) {
            return;
        }
        
        $member->points = $event->newPoints;
        $member->save();
    }

    /**
     * 记录积分流水
     */
    private function recordPointsLog(PointsChangedEvent $event): void
    {
        /** @var MemberPointsDao $dao */
        $dao = Container::make(MemberPointsDao::class);
        
        $dao->save([
            'member_id' => $event->memberId,
            'type' => $event->type->value,
            'points' => $event->points,
            'balance' => $event->newPoints,
            'remark' => $event->remark,
            'related_id' => $event->relatedId
        ]);
    }

    /**
     * 更新会员等级
     */
    private function updateMemberLevel(PointsChangedEvent $event): void
    {
        // ... 等级更新逻辑
        
        // 触发新事件
        $levelEvent = new MemberLevelUpdatedEvent(...);
        $levelEvent->dispatch();
    }
}
```

## 异常处理

监听器中的异常应该被捕获，不影响主流程：

```php
public function handle(XXXEvent $event): void
{
    try {
        // 业务逻辑
    } catch (\Exception $e) {
        // 记录日志但不影响主流程
        error_log('XXXListener error: ' . $e->getMessage());
    }
}
```

## 路径变量

| 变量 | App | Plugin |
|------|-----|--------|
| `{namespace}` | `app\adminapi\listener` | `plugin\{Plugin}\app\adminapi\listener` |

## 生成示例

### 登录日志监听器

```
事件: LoginLogEvent
```

生成文件: `app/adminapi/listener/LoginLogListener.php`

### 积分变动监听器

```
事件: PointsChangedEvent
```

生成文件: `app/adminapi/listener/PointsChangedListener.php`

## 注意事项

1. **命名对应**：监听器名称与事件名称对应
2. **handle 方法**：监听器必须包含 `handle` 方法
3. **事件类型**：handle 方法参数必须指定具体的事件类
4. **异常处理**：建议捕获异常，避免影响主流程
5. **事件注册**：监听器需要在 `config/event.php` 中注册才能生效
