---
name: madong-frontend-shared-i18n
description: 前端共享国际化规范，JSON 结构 + 加载器（admin/platform/install 共用）
globs:
  - "apps/**/src/locales/**/*.json"
  - "apps/**/src/lang/**/*"
---

## 三种 i18n 加载模式

系统支持三种语言包加载模式，通过不同的目录位置区分：

| # | 目录 | 模式 | Key 生成规则 |
|---|------|------|-------------|
| 1 | `lang/` | 目录+文件+key | 目录名=第一段key, 文件名=第二段key, 文件内key=后续段 |
| 2 | `plugins/*/lang/` | 插件+目录+文件+key | 插件名=第一段key, 同模式1 |
| 3 | `locales/langs/` | root 模式 + 目录+文件+key | 根目录下文件: 文件名=根key; 子目录下文件: 同模式1 |

**核心规则变更** (相比旧版):
- ✅ **目录与文件名共同参与 key 生成**（不再是"仅归档用途"）
- ✅ **文件名允许包含点号**，点号在文件名中同样作为 key 层级分隔符
- ✅ **目录与点号文件名等价**：`system/menu.json` = `system.menu.*`，`system.menu.json` = `system.menu.*`（效果相同）
- ✅ **多文件模块建议用目录**，单文件模块可用点号文件名减少目录层级

## 文件位置

### 1. `lang/` — 应用语言包（目录+文件+key 模式）

```
apps/{app}/src/lang/
├── zh-CN/
│   ├── system/
│   │   ├── config.json              → key 前缀: system.config
│   │   ├── dept.json                → key 前缀: system.dept
│   │   ├── dict.json                → key 前缀: system.dict
│   │   ├── dict.item.json           → key 前缀: system.dict.item（点号文件名，等价于 dict/item.json）
│   │   ├── menu.json                → key 前缀: system.menu
│   │   ├── user.json                → key 前缀: system.user
│   │   └── user.center.json         → key 前缀: system.user.center（点号文件名，等价于 user/center.json）
│   ├── components/
│   │   ├── crud.json                → key 前缀: components.crud
│   │   ├── dialog.json              → key 前缀: components.dialog
│   │   ├── form.json                → key 前缀: components.form
│   │   └── render.json              → key 前缀: components.render
│   ├── member/
│   │   ├── level.json               → key 前缀: member.level
│   │   ├── tag.json                 → key 前缀: member.tag
│   │   ├── tag.auth.json            → key 前缀: member.tag.auth（点号文件名）
│   │   ├── tag.user.json            → key 前缀: member.tag.user（点号文件名）
│   │   └── user.json                → key 前缀: member.user
│   ├── ops/
│   │   ├── crontab.json             → key 前缀: ops.crontab
│   │   ├── crontab.log.json         → key 前缀: ops.crontab.log（点号文件名）
│   │   ├── gateway.json             → key 前缀: ops.gateway
│   │   ├── gateway.blacklist.json   → key 前缀: ops.gateway.blacklist（点号文件名）
│   │   ├── gateway.limiter.json     → key 前缀: ops.gateway.limiter（点号文件名）
│   │   ├── logs.login.json          → key 前缀: ops.logs.login（点号文件名）
│   │   ├── logs.operate.json        → key 前缀: ops.logs.operate（点号文件名）
│   │   └── server.json              → key 前缀: ops.server
│   ├── plugin/
│   │   ├── delegation.json          → key 前缀: plugin.delegation
│   │   ├── plugin.develop.json      → key 前缀: plugin.plugin.develop（点号文件名）
│   │   └── tenant.json              → key 前缀: plugin.tenant
│   ├── devtools/
│   │   ├── features.json            → key 前缀: devtools.features
│   │   ├── files.json               → key 前缀: devtools.files
│   │   ├── generator.code.json      → key 前缀: devtools.generator.code（点号文件名）
│   │   └── terminal.json            → key 前缀: devtools.terminal
│   ├── web/
│   │   ├── link.json                → key 前缀: web.link
│   │   └── menu.json                → key 前缀: web.menu
│   ├── content/
│   │   ├── message.json             → key 前缀: content.message
│   │   ├── notice.json              → key 前缀: content.notice
│   │   └── review.json              → key 前缀: content.review
│   ├── member.json                  → key 前缀: member（根目录文件）
│   ├── ops.json                     → key 前缀: ops（根目录文件）
│   ├── setting.json                 → key 前缀: setting（根目录文件）
│   ├── system.json                  → key 前缀: system（根目录文件）
│   └── web.json                     → key 前缀: web（根目录文件）
└── en-US/
    └── (同上结构)
```

- 目录与文件名共同参与 key 生成
- 文件名**允许含点号**，点号与目录分隔符一样参与 key 层级：`user.center.json` → `$t('system.user.center.*')` 等价于 `user/center.json`
- 多文件模块建议用目录组织，单文件模块可用点号文件名减少目录层级
- 根目录下文件（如 `setting.json`）使用单段 key：`$t('setting.*')`
- 加载器：`loadAppLangLocales()`（使用 `extractDirFileKeys` 解析）

### 2. `plugins/*/lang/` — 插件语言包（插件+目录+文件+key 模式）

```
apps/{app}/src/plugins/{plugin}/lang/
├── zh-CN/
│   ├── captcha.json               → key 前缀: {plugin}.captcha
│   ├── crud/
│   │   ├── basic.json             → key 前缀: {plugin}.crud.basic
│   │   ├── tree.json              → key 前缀: {plugin}.crud.tree
│   │   └── tree.select.json       → key 前缀: {plugin}.crud.tree.select（点号文件名，等价于 tree/select.json）
│   └── form/
│       ├── api.json               → key 前缀: {plugin}.form.api
│       └── basic.json             → key 前缀: {plugin}.form.basic
└── en-US/
    └── (同上结构)
```

- 插件名自动作为 key 前缀（防止与主应用 key 冲突）
- 其余同模式1：目录+文件+key
- 加载器：`loadPluginLocales()`（使用 `extractPluginFileKeys` 解析）

### 3. `locales/langs/` — 框架内置语言包（root 模式 + 目录+文件+key）

```
apps/{app}/src/locales/
├── index.ts                    # 国际化配置初始化
├── loader/                     # 加载器
└── langs/
    ├── zh-CN/
    │   ├── common.json          → key 前缀: common（root 模式）
    │   ├── page.json            → key 前缀: page（root 模式）
    │   └── system/                        ← 子目录 = 目录+文件+key
    │       └── menu.json        → key 前缀: system.menu
    └── en-US/
        └── (同上结构)
```

- **根目录下文件**：root 模式，文件名直接作为根 key
- **子目录下文件**：目录+文件+key（同模式1）
- 两种模式在同一个目录树共存
- 加载器：`loadLocalesLangs()`（使用 `extractRootFileKeys` 解析）

### 加载优先级

`loadAllLocaleMessages()` 按顺序 deepMerge，后加载覆盖前：
1. `locales/langs/` → 框架内置通用翻译（root + 目录+文件+key）
2. `lang/` → 业务模块翻译（目录+文件+key）
3. `plugins/**/lang/` → 插件翻译（插件名+目录+文件+key）

## JSON 结构

### `locales/langs/`（通用翻译）

```json
// key 前缀由加载模式决定
// 根目录下文件(如 common.json)：$t('common.success')
// 子目录下文件(如 system/menu.json)：$t('system.menu.xxx')
{
  "success": "操作成功",
  "loading": "加载中...",
  "operate": {
    "save": "保存"
  },
  "crud": {
    "create": "新增"
  }
}
```

### `lang/`（业务模块）

```json
// zh-CN/system/menu.json → 目录 system + 文件名 menu → $t('system.menu.xxx')
{
  "name": "菜单名称",
  "code": "菜单标识",
  "status": "状态",
  "sort": "排序",
  "create_time": "创建时间"
}
```

```json
// en-US/system/menu.json（key 不变，value 翻译）
{
  "name": "Name",
  "code": "Code",
  "status": "Status",
  "sort": "Sort",
  "create_time": "Created At"
}
```

## 使用方式

```vue
<template>
  <!-- lang/ 示例：lang/zh-CN/system/menu.json → system.menu.xxx -->
  <span>{{ $t('system.menu.name') }}</span>

  <!-- locales/langs/ root 示例：common.json → common.xxx -->
  <span>{{ $t('common.operate.save') }}</span>

  <!-- locales/langs/ 子目录示例：system/menu.json → system.menu.xxx -->
  <span>{{ $t('system.menu.name') }}</span>
</template>

<script setup lang="ts">
import { $t } from '#/locales';

// lang/ → 目录+文件=key 前缀
const label = $t('system.menu.name');
// locales/langs/ root 模式
const tip = $t('common.operate.save');
</script>
```

## 关键约定

- **目录与文件名共同参与 key 生成**，目录名及文件名中的点号均为 key 层级
- **文件名允许包含点号**，`user.center.json` = key 层级 `user.center`
- **目录优先于文件名**：多文件模块用目录，单文件模块用点号文件名
- **`locales/langs/`**：根目录文件用 root 模式（文件名点号均计入 key），子目录文件用目录+文件+key
- **`plugins/*/lang/`**：插件名自动注入为 key 前缀
- 三个来源最终 deepMerge 到一个命名空间，key 不可冲突
- **冲突提示**：若 `system/menu.json` 和 `system.menu.json` 同时存在会产出相同 key `system.menu`，加载器会按读取顺序覆盖
- key 命名使用小写 snake_case（如 `create_time`、`batch_delete`）
- zh-CN 和 en-US 的 key 结构必须一致
- 翻译文本中可以使用 `{variable}` 插值
- 组件中的静态文本必须使用 `$t()` 而非硬编码
- 每个前端站点（admin/platform）有自己的 `locales/` 和 `lang/` 目录

## 检查清单

- [ ] 选对了文件位置：通用翻译 → `locales/langs/`，业务模块 → `lang/`
- [ ] `locales/langs/` 根目录文件使用 root 模式（文件名点号也计入 key，如 `system.menu.json` → `system.menu`）
- [ ] `locales/langs/` 子目录文件使用 目录+文件+key 模式
- [ ] `lang/` 使用目录+文件+key 模式，文件名中的点号也参与 key 层级
- [ ] `plugins/*/lang/` 自动带有插件名前缀
- [ ] zh-CN 和 en-US 两个目录是否都更新了
- [ ] 组件中的文案是否使用了 `$t()` 而非硬编码
- [ ] key 是否使用小写 snake_case（如 `create_time`）
- [ ] 多文件模块用目录，单文件模块用点号文件名（如 `system/menu.json` + `user.center.json`）
