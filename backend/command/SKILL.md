---
name: madong-backend-command
description: 命令行命令规范，基于 Symfony Console
globs:
  - "app/**/command/**/*.php"
---

## 文件位置

```
app/command/{Name}Command.php
```

## 命令类型

| 类型 | 示例 | 说明 |
|------|------|------|
| 安装命令 | `InstallCommand`, `MigrateCommand` | 应用安装和迁移 |
| 代码生成命令 | `ControllerCommand`, `DaoCommand`, `ModelCommand`, `ServiceCommand`, `ValidateCommand`, `MiddlewareCommand` | CRUD 代码生成 |
| 插件管理命令 | `PluginInstallCommand`, `PluginCreateCommand`, `PluginDevelopCommand` | 插件生命周期管理 |
| 数据命令 | `TenantDataMigrateCommand` | 租户数据迁移 |
| 配置命令 | `ConfigMySQLCommand` | MySQL 配置管理 |
| 元数据命令 | `CollectCommand` | 元数据收集 |
| 检测命令 | `CheckIntegrityCommand` | 完整性检查 |

## 代码模板

```php
<?php
declare(strict_types=1);

namespace app\command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class {Name}Command extends Command
{
    protected static $defaultName = '{command_name}';

    protected function configure(): void
    {
        $this->setDescription('{描述}')
             ->addArgument('{arg}', InputArgument::REQUIRED, '{参数说明}');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        // 命令逻辑
        $output->writeln('执行成功');
        return Command::SUCCESS;
    }
}
```

## 关键约定

- `$defaultName` 定义命令名称，格式 `{action}:{target}`（如 `gen:controller`）
- `configure()` 定义参数和选项
- `execute()` 返回 `Command::SUCCESS` 或 `Command::FAILURE`
- 代码生成命令的 Stub 模板位于 `app/command/stubs/` 目录
- 安装命令仅在安装流程中使用

## 检查清单

- [ ] 是否设置了 `$defaultName`
- [ ] `configure()` 是否定义了命令描述和参数
- [ ] `execute()` 是否正确返回状态码
- [ ] 如果使用了 Stub 模板，模板路径是否正确
