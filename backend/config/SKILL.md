---
name: madong-backend-config
description: 配置体系规范，28个配置文件的约定
globs:
  - "config/**/*.php"
---

## 配置文件索引

| 文件 | 说明 | 关联技能 |
|------|------|---------|
| `app.php` | 应用基础配置（名称/时区/debug） | - |
| `database.php` | 数据库连接配置 | migrate |
| `route.php` | 路由注册配置 | route |
| `event.php` | 事件-监听器映射 | event, listener |
| `middleware.php` | 全局中间件链 | middleware |
| `process.php` | 自定义进程 | process |
| `crontab.php` | 定时任务 | crontab |
| `tenant.php` | 多租户模式配置 | scope |
| `message.php` | SSE/消息配置 | controller, api |
| `log.php` | 日志配置 | logger |
| `cache.php` | 缓存配置 | - |
| `redis.php` | Redis 连接配置 | queue |
| `container.php` | DI 容器配置 | - |
| `dependence.php` | 依赖注入配置 | - |
| `exception.php` | 异常配置 | exception |
| `morph_map.php` | 多态关联映射 | model |
| `bootstrap.php` | 启动引导类注册 | bootstrap |
| `autoload.php` | 自动加载配置 | - |
| `server.php` | 服务器配置 | - |
| `session.php` | Session 配置 | - |
| `static.php` | 静态资源配置 | - |
| `storage.php` | 存储配置 | - |
| `translation.php` | 翻译配置 | lang |
| `view.php` | 视图配置 | - |
| `review.php` | 审核相关配置 | - |
| `terminal.php` | 终端配置 | - |
| `recycle_bin.php` | 回收站配置 | - |
| `third_party.php` | 第三方服务配置 | - |

## 关键约定

- 所有配置文件返回 `array`
- 配置加载顺序：`config/` → `config/plugin/` → `core/{module}/config/`
- 环境变量使用 `env('KEY', default)` 读取
- `tenant.php` 中的 `enable` 和 `mode` 控制多租户行为
- `morph_map.php` 中的映射通过 `MorphMapBootstrap` 注册

## 检查清单

- [ ] 新配置是否按照正确的文件名和格式创建
- [ ] 环境变量是否使用 `env()` 函数读取
- [ ] 敏感配置是否通过环境变量注入而非硬编码
