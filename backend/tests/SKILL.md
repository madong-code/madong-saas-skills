---
name: madong-backend-tests
description: 后端测试规范，PHPUnit
globs:
  - "tests/**/*.php"
---

## 文件位置

```
tests/
├── unit/            # 单元测试
├── integration/     # 集成测试
├── e2e/             # 端到端测试
└── scripts/         # 测试脚本
```

## 命名规范

```
tests/{type}/{module}-{model}-test.php
```

示例：`tests/unit/system-menu-test.php`

## 代码模板

```php
<?php

use PHPUnit\Framework\TestCase;

class SystemMenuTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // 测试初始化
    }

    public function testMenuItemCreation(): void
    {
        // 测试逻辑
        $this->assertTrue(true);
    }

    public function testMenuItemDeletion(): void
    {
        // 测试逻辑
        $this->assertEmpty([]);
    }
}
```

## 关键约定

- 单元测试命名格式：`{module}-{model}-test.php`
- 测试方法使用 `test` 前缀或 `#[Test]` 属性
- 每个测试类仅测试一个类或一个功能模块
- 测试数据使用 Factory 或 Seeder 生成，不依赖外部环境
- PHPUnit 配置文件位于 `phpunit.xml`

## 检查清单

- [ ] 文件名是否符合 `{module}-{model}-test.php` 格式
- [ ] 测试方法是否覆盖了正常和异常场景
- [ ] 是否使用了 `setUp()` / `tearDown()` 管理测试资源
