---
name: madong-backend-crontab
description: 定时任务规范，基于 scheduler 调度器
globs:
  - "config/crontab.php"
---

## 配置文件

```
config/crontab.php
```

## 定时任务配置

```php
<?php
/**
 * 定时任务配置
 */

use core\infrastructure\scheduler\event\EvalTask;
use core\infrastructure\scheduler\event\SchedulingTask;
use core\infrastructure\scheduler\event\ShellTask;
use core\infrastructure\scheduler\event\UrlTask;

return [
    // 启用定时任务调度器
    'enable' => env('CRONTAB_ENABLED', false),

    // 任务定义
    'tasks' => [
        [
            'name' => '数据清理',
            'cron' => '0 3 * * *',         // 每天凌晨3点
            'task' => SchedulingTask::class,
            'args' => [
                'target' => [\app\service\core\system\CleanService::class, 'cleanExpiredData'],
            ],
            'enable' => true,
        ],
        [
            'name' => '日志归档',
            'cron' => '0 2 * * 0',         // 每周日凌晨2点
            'task' => SchedulingTask::class,
            'args' => [
                'target' => [\app\service\core\system\LogService::class, 'archive'],
            ],
            'enable' => true,
        ],
    ],
];
```

## 任务类型

| 类型 | 说明 |
|------|------|
| `SchedulingTask` | 调用指定类的静态方法 |
| `EvalTask` | 执行 PHP 代码 |
| `ShellTask` | 执行 Shell 命令 |
| `UrlTask` | 请求指定 URL |

## 调度器配置 (`core/infrastructure/config/scheduler.php`)

```php
return [
    'enable' => true,
    'crontab_config' => config_path() . '/crontab.php',
];
```

## 关键约定

- 定时任务配置在 `config/crontab.php`，框架层调度器读取后执行
- cron 表达式格式：`分 时 日 月 周`
- 定时任务仅在 `enable = true` 时生效
- 任务执行失败应自行记录日志
- 长时间任务建议使用队列而不是定时任务

## 检查清单

- [ ] cron 表达式是否正确
- [ ] 任务类/方法是否存在
- [ ] `enable` 是否设置为 `true`
