---
name: madong-backend-process
description: 自定义进程规范，基于 Workerman 的进程配置
globs:
  - "app/**/process/**/*.php"
---

## 文件位置

```
app/process/{Name}.php
```

## 进程配置 (`config/process.php`)

```php
return [
    'monitor' => [
        'handler' => app\process\Monitor::class,
        'reloadable' => false,
        'constructor' => [
            'monitorDir' => [app_path(), config_path()],
            'monitorExtensions' => ['php'],
            'options' => ['enable_file_monitor' => true],
        ],
    ],
    // 可添加更多自定义进程
];
```

## 进程模板

```php
<?php
declare(strict_types=1);

namespace app\process;

use Workerman\Worker;

class {Name}
{
    public function onWorkerStart(Worker $worker): void
    {
        // 进程启动时的逻辑
    }

    public function onWorkerStop(Worker $worker): void
    {
        // 进程停止时的逻辑
    }
}
```

## 关键约定

- 进程通过 `config/process.php` 注册
- 文件监控进程默认启用，监听 `app/` 和 `config/` 目录的 `.php` 文件变更
- 自定义进程需要实现 `onWorkerStart` 和 `onWorkerStop` 方法
- 常驻进程注意内存泄漏，定期释放资源

## 检查清单

- [ ] 进程是否已在 `config/process.php` 中注册
- [ ] 是否实现了 `onWorkerStart` / `onWorkerStop` 方法
- [ ] 常驻进程是否有内存管理机制
