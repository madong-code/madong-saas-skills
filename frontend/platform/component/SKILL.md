---
name: madong-frontend-platform-component
description: Platform 特有组件规范，notification-drawer 消息通知抽屉
globs:
  - "apps/platform/src/components/notification-drawer/**/*"
---

## Platform 特有组件

Platform 除了共享的基础组件（crud/dialog/form/render/icon/page，见 `shared/component`），还有以下特有组件：

### notification-drawer/ - 消息通知抽屉

```typescript
// Platform 端的消息通知抽屉组件
// 用于展示系统通知、告警等信息
// 与 Admin 的 notify Store 不同，Platform 使用抽屉式 UI 而非 WebSocket Push
```

## 关键约定

- Platform 特有组件放在 `components/` 目录下，与共享组件并列
- 组件命名使用大驼峰
- notification-drawer 是 Platform 独有的消息通知方式

## 检查清单

- [ ] 组件命名是否使用大驼峰
- [ ] 是否正确区分了 Platform 与 Admin 的通知方式
