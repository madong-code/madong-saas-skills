---
name: madong-backend-exception
description: 异常体系规范，15种异常类 + Handler + Logger
globs:
  - "core/**/exception/**/*.php"
---

## 异常继承链

```
BaseException
├── AdminException           # 管理后台业务异常
├── TenantException          # 租户业务异常
├── CommonException          # 通用业务异常
├── ValidationException      # 验证失败异常
├── CaptchaException         # 验证码错误异常
├── PluginException          # 插件相关异常
├── UploadException          # 上传相关异常
├── SubscriptionException    # 订阅/套餐异常
├── AccessDeniedHttpException    # 403 无权限
├── ForbiddenHttpException       # 403 禁止访问
├── NotFoundHttpException        # 404 资源不存在
├── UnauthorizedHttpException    # 401 未认证
├── BadRequestHttpException      # 400 错误请求
├── TooManyRequestsHttpException # 429 请求过多
└── ServerErrorHttpException     # 500 服务器错误
```

## 使用方式

```php
use core\foundation\exception\handler\AdminException;
use core\foundation\exception\handler\CommonException;
use core\foundation\exception\handler\ValidationException;

// 抛出业务异常
throw new AdminException('菜单不存在');
throw new CommonException('操作失败，请重试');

// 带错误码的异常
throw new AdminException('权限不足', 403);

// 验证异常（自动返回400）
throw new ValidationException('参数验证失败');
```

## Handler 处理流程

`Handler.php` 统一处理异常：

1. 记录异常日志到 `runtime/logs/exception/`
2. 根据异常类型设置 HTTP 状态码
3. 开发环境（debug=true）返回详细错误信息
4. 生产环境（debug=false）返回友好提示

```php
// 响应格式
{
    "code": -1,
    "msg": "菜单不存在",
    "data": null
}
```

## 关键约定

- 业务异常使用 `AdminException` / `CommonException`，HTTP 状态码 200（`code=-1`）
- HTTP 状态码异常使用 `NotFoundHttpException` / `ForbiddenHttpException` 等
- 前端根据 `code` 字段判断成功（0）或失败（非0）
- 异常消息使用中文，用户可见
- 生产环境不暴露技术细节和堆栈信息
- 所有异常建议在业务代码中捕获处理，避免未捕获异常导致500

## 检查清单

- [ ] 业务异常使用 `AdminException` 而非 `\Exception`
- [ ] 异常消息是否为中文且对用户友好
- [ ] 是否需要 HTTP 状态码异常（400/401/403/404/429/500）
- [ ] 是否在 try-catch 中正确处理了异常
