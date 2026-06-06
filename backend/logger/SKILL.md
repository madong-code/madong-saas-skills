---
name: madong-backend-logger
description: 日志规范，8级日志 + 操作日志 + 异常日志
globs:
  - "core/**/logger/**/*.php"
---

## 日志位置

```
runtime/log/{level}/{date}.log
```

## 日志级别（8级）

| 级别 | 方法 | 说明 |
|------|------|------|
| debug | `Logger::debug($msg, $context)` | 调试信息 |
| info | `Logger::info($msg, $context)` | 一般信息 |
| notice | `Logger::notice($msg, $context)` | 注意 |
| warning | `Logger::warning($msg, $context)` | 警告 |
| error | `Logger::error($msg, $context)` | 错误 |
| critical | `Logger::critical($msg, $context)` | 严重 |
| alert | `Logger::alert($msg, $context)` | 警报 |
| emergency | `Logger::emergency($msg, $context)` | 紧急 |

## 日志配置 (`config/log.php`)

```php
return [
    'default' => [
        'handlers' => [
            [
                'class' => Monolog\Handler\RotatingFileHandler::class,
                'constructor' => [
                    runtime_path() . '/logs/{level}/{date}.log',
                    30, // 保留30天
                    Monolog\Level::Debug,
                ],
                'formatter' => [
                    'class' => Monolog\Formatter\LineFormatter::class,
                    'constructor' => [null, 'Y-m-d H:i:s', true],
                ],
            ],
        ],
    ],
];
```

## 使用方式

```php
use core\infrastructure\logger\Logger;

// 基本日志
Logger::info('用户登录成功', ['user_id' => 123, 'ip' => '127.0.0.1']);
Logger::error('数据库连接失败', ['db' => 'mysql', 'error' => $e->getMessage()]);

// 上下文支持
Logger::warning('请求超时', [
    'url' => $request->uri(),
    'method' => $request->method(),
    'duration' => $duration,
]);
```

## 操作日志

操作日志通过 `OperationMiddleware` 自动记录（AdminAPI 控制器），记录到 `log_operation` 表：

```php
// 字段
'id'          // 雪花ID
'admin_id'    // 操作人ID
'url'         // 请求路径
'method'      // 请求方法
'ip'          // IP地址
'params'      // 请求参数(JSON)
'result'      // 响应结果
'status'      // 状态
'created_at'  // 创建时间
```

## 异常日志

通过 `core\foundation\exception\Logger` 记录：

```php
// 自动记录到 runtime/logs/exception/ 目录
// 包含异常堆栈、请求上下文等信息
```

## 关键约定

- 业务日志使用 `Logger::info()` / `Logger::error()` 静态方法
- 生产环境日志级别设为 `warning`（`config/log.php` 中配置）
- 敏感数据（密码/令牌）不能写入日志
- 操作日志自动记录，无需手动添加
- 异常日志自动记录，无需手动添加
- 日志按级别和日期分割存储

## 检查清单

- [ ] 是否使用了正确的日志级别
- [ ] 敏感信息是否已过滤
- [ ] 上下文信息是否有助于问题排查
- [ ] 日志消息是否清晰可读
