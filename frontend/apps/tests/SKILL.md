---
name: madong-frontend-apps-tests
description: 前端测试规范
globs:
  - "apps/**/__tests__/**/*.ts"
---

## 文件位置

```
apps/{app}/src/__tests__/{module}/{name}.test.ts
```

## 关键约定

- 使用 Vitest 作为测试框架
- 测试文件放在 `__tests__/` 目录下
- 测试文件名：`{name}.test.ts`
- 测试覆盖率目标：核心业务逻辑 >= 80%

## 检查清单

- [ ] 是否覆盖了核心业务逻辑
- [ ] 测试是否可独立运行
- [ ] 是否使用了正确的断言方式
