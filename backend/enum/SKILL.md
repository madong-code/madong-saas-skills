---
name: madong-backend-enum
description: 枚举规范，实现 IEnum 接口
globs:
  - "app/**/enum/**/*.php"
---

## 文件位置

```
app/enum/{module}/{Name}Enum.php
```

按模块分组：

| 分组 | 路径 | 示例 |
|------|------|------|
| 公共 | `app/enum/common/` | `StatusEnum`, `LangEnum`, `YesNoEnum` |
| 会员 | `app/enum/member/` | `MemberLevelEnum`, `MemberStatusEnum` |
| 系统 | `app/enum/system/` | `MenuTypeEnum`, `AdminStatusEnum` |
| 平台 | `app/enum/platform/` | `PlatformConfigEnum` |
| 插件 | `app/enum/plugin/` | `PluginStatusEnum` |
| 审核 | `app/enum/review/` | `ReviewStatusEnum` |
| Web | `app/enum/web/` | `WebPageEnum` |
| 终端 | `app/enum/terminal/` | `TerminalStatusEnum` |

## 接口说明

### IEnum (`core\foundation\interface\IEnum`)

```php
interface IEnum
{
    public function getValue(): mixed;  // 获取枚举值
    public function getLabel(): string; // 获取枚举标签
}
```

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\enum\common;

use core\foundation\interface\IEnum;

enum StatusEnum: int implements IEnum
{
    case ENABLED = 1;
    case DISABLED = 0;

    public function getValue(): int
    {
        return $this->value;
    }

    public function getLabel(): string
    {
        return match($this) {
            self::ENABLED  => '启用',
            self::DISABLED => '禁用',
        };
    }
}
```

## 使用方式

```php
// 取值
StatusEnum::ENABLED->value;       // 1
StatusEnum::ENABLED->getValue();  // 1
StatusEnum::ENABLED->getLabel();  // '启用'

// 对比
if ($status === StatusEnum::ENABLED->value) { ... }

// 遍历
foreach (StatusEnum::cases() as $case) {
    $case->value;   // 枚举值
    $case->name;    // 枚举名（大写）
}
```

## 目标变量表

| 变量 | 值 |
|------|-----|
| `{module}` | common/member/system/platform/plugin/review/web/terminal |
| `{Name}` | Status/MemberLevel/MenuType/PlatformConfig 等 |

## 关键约定

- 枚举必须实现 `IEnum` 接口
- 枚举类型使用 `int`（推荐）或 `string` backed enum
- `getValue()` 返回枚举值，`getLabel()` 返回中文标签
- 枚举按模块分组存放，公共枚举放在 `common/` 目录
- 状态类枚举建议包含 `ENABLED`/`DISABLED` 或 `ACTIVE`/`INACTIVE`
- 枚举值使用正整数（1、2、3），不使用负数或 0
- 枚举标签必须返回中文

## 检查清单

- [ ] 是否实现了 `IEnum` 接口
- [ ] `getValue()` 和 `getLabel()` 是否都已实现
- [ ] 枚举值是否为正整数
- [ ] 标签是否为中文
- [ ] 是否按模块放在正确的分组目录下
