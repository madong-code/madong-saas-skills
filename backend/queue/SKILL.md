---
name: madong-backend-queue
description: Redis 队列消费者规范，继承 BaseQueueConsumer
globs:
  - "app/**/queue/**/*.php"
---

## 文件位置

```
app/queue/redis/{Name}Consumer.php
```

## 基类说明

### BaseQueueConsumer (`core\foundation\base\BaseQueueConsumer`)

```php
abstract class BaseQueueConsumer
{
    abstract public function consume(mixed $data): bool;
}
```

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\queue\redis;

use core\foundation\base\BaseQueueConsumer;
use support\Log;

class {Name}Consumer extends BaseQueueConsumer
{
    public function consume(mixed $data): bool
    {
        try {
            // 处理消息
            Log::info('队列消费成功', ['data' => $data]);
            return true;  // 消费成功
        } catch (\Throwable $e) {
            Log::error('队列消费失败', ['error' => $e->getMessage()]);
            return false; // 消费失败，重新入队
        }
    }
}
```

## 配置

在 `config/redis.php` 中配置队列连接，在 `config/process.php` 中配置消费进程。

## 关键约定

- `consume()` 返回 `true` 表示消费成功，`false` 表示失败（重新入队）
- 消费者中必须自行捕获异常，不能抛出
- 消费者不直接操作数据库，应通过 Service/DAO 层处理
- 队列消息应尽量轻量化，只传递必要的数据 ID 而非完整数据

## 检查清单

- [ ] 是否继承 `BaseQueueConsumer`
- [ ] `consume()` 是否返回 `bool`
- [ ] 异常是否在消费者内部捕获处理
