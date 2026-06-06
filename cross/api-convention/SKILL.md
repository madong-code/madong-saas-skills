---
name: madong-cross-api-convention
description: 前后端 API 对接规范，响应格式/错误码/查询操作符/分页
globs:
  - "**/*.php"
  - "**/*.ts"
---

## 响应格式

### 成功响应

```json
{
  "code": 0,
  "msg": "ok",
  "data": {
    "items": [...],
    "total": 100
  }
}
```

### 失败响应

```json
{
  "code": -1,
  "msg": "菜单不存在",
  "data": null
}
```

### HTTP 状态码异常响应

```json
{
  "code": -1,
  "msg": "认证已过期，请重新登录",
  "data": null
}
```

## 错误码

| code | 说明 |
|------|------|
| 0 | 成功 |
| -1 | 业务失败（通用） |
| 400 | 请求参数错误 |
| 401 | 未认证/令牌过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 429 | 请求太频繁 |
| 500 | 服务器内部错误 |

## 查询操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `LIKE_` | 模糊匹配 | `LIKE_name=菜单` |
| `EQ_` | 精确匹配 | `EQ_status=1` |
| `EQINT_` | 整数精确匹配 | `EQINT_id=1` |
| `NEQ_` | 不等于 | `NEQ_status=0` |
| `GT_` | 大于 | `GT_sort=10` |
| `LT_` | 小于 | `LT_sort=100` |
| `GTE_` | 大于等于 | `GTE_created_at=1700000000` |
| `LTE_` | 小于等于 | `LTE_created_at=1800000000` |
| `IN_` | IN 查询 | `IN_id=1,2,3` |
| `BETWEEN_` | 范围查询 | `BETWEEN_created_at=1700000000,1800000000` |
| `NOTNULL_` | 不为空 | `NOTNULL_mobile=` |

## 分页参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `page` | int | 1 | 页码 |
| `limit` | int | 15 | 每页条数 |
| `field` | string | '' | 排序字段 |
| `order` | string | 'desc' | 排序方向 |
| `sort` | string | '' | 自定义排序 |
| `format` | string | 'normal' | 输出格式: normal/select/tree/table_tree |

## 后端返回示例

```php
use core\foundation\tool\Json;

// 成功
return Json::success(['items' => $list, 'total' => $total]);

// 分页
return Json::success([
    'items' => $list->items(),
    'total' => $list->total(),
]);

// 失败
return Json::fail('菜单不存在');

// 带错误码
return Json::fail('认证已过期', 401);
```

## 前端调用示例

```typescript
import { requestClient } from '#/api/request';

// GET 请求（自动处理分页参数）
const res = await requestClient.get('/system/menu', {
  params: { page: 1, limit: 15, LIKE_name: '系统' }
});
// res = { code: 0, msg: 'ok', data: { items: [...], total: 100 } }

// POST 请求
const res = await requestClient.post('/system/menu', { name: '测试' });

// PUT 请求
const res = await requestClient.put('/system/menu/1', { name: '更新' });

// DELETE 请求
const res = await requestClient.delete('/system/menu/1');
```

## 关键约定

- 所有接口返回统一 JSON 格式 `{code, msg, data}`
- `code=0` 表示成功，`code!=0` 表示失败
- 业务错误用 `code=-1`，HTTP 错误用 HTTP 状态码
- 列表接口返回 `{items: [], total: N}` 格式
- 查询操作符通过 URL query 传参
- 前端 `requestClient` 自动处理成功/失败拦截

## 检查清单

- [ ] 返回格式是否为 `{code, msg, data}`
- [ ] 成功时 `code` 是否为 0
- [ ] 列表接口是否返回 `items` 和 `total`
- [ ] 查询参数是否使用了标准操作符
- [ ] 错误消息是否为中文且用户友好
