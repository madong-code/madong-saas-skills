---
name: madong-cross-git-convention
description: Git 提交规范，lefthook + commitlint + czg + 分支命名
globs:
  - "**/*.ts"
  - "**/*.php"
  - "**/*.vue"
  - "**/*.js"
---

## 工具链

| 工具 | 用途 | 配置位置 |
|------|------|----------|
| lefthook | Git hooks 管理 | `frontend/lefthook.yml` |
| commitlint | 提交信息校验 | `frontend/.commitlintrc.js` → `@vben/commitlint-config` |
| czg | 交互式提交 | `pnpm commit` |

## 提交格式

```
<type>(<scope>): <subject>
```

### type 枚举

| type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `perf` | 性能优化 |
| `style` | UI 样式变更 |
| `docs` | 文档更新 |
| `test` | 测试相关 |
| `refactor` | 重构 |
| `build` | 构建/依赖变更 |
| `ci` | CI 配置变更 |
| `chore` | 工具/配置变更 |
| `revert` | 回退 |
| `types` | 类型定义变更 |
| `release` | 发版 |

### scope 枚举

scope 从 workspace 包名动态生成，加上固定选项：

| scope | 说明 |
|-------|------|
| `@madong/admin` | Admin 前端 |
| `@madong/platform` | Platform 前端 |
| `@madong/install` | Install 前端 |
| `project` | 项目级 |
| `style` | 样式 |
| `lint` | Lint 配置 |
| `ci` | CI 配置 |
| `dev` | 开发环境 |
| `deploy` | 部署 |
| `other` | 其他 |

### 规则

- header 最大长度：108 字符
- subject 和 type 不能为空
- 扩展自 `@commitlint/config-conventional`

## czg 快捷别名

```bash
pnpm commit :b   # build: bump dependencies
pnpm commit :c   # chore: update config
pnpm commit :f   # docs: fix typos
pnpm commit :r   # docs: update README
pnpm commit :s   # style: update code format
```

## lefthook 钩子

### pre-commit（并行执行）

| 任务 | glob | 执行命令 |
|------|------|----------|
| `lint-md` | `*.md` | `pnpm oxfmt {staged_files}` |
| `lint-vue` | `*.vue` | `pnpm oxfmt` → `pnpm oxlint --fix` → `pnpm eslint --cache --fix` → `pnpm stylelint --fix` |
| `lint-js` | `*.{js,jsx,ts,tsx}` | `pnpm oxfmt` → `pnpm oxlint --fix` → `pnpm eslint --cache --fix` |
| `lint-style` | `*.{scss,less,styl,html,vue,css}` | `pnpm oxfmt` → `pnpm stylelint --fix` |
| `lint-package` | `package.json` | `pnpm oxfmt` |
| `lint-json` | `*.json` | `pnpm oxfmt` |
| `code-workspace` | - | `pnpm vsh code-workspace --auto-commit` |

### commit-msg

```bash
pnpm exec commitlint --edit $1
```

### post-merge

```bash
pnpm install
```

## 分支命名规范

| 分支 | 格式 | 示例 |
|------|------|------|
| 功能 | `feat/{module}-{desc}` | `feat/member-points` |
| 修复 | `fix/{module}-{desc}` | `fix/auth-token-expire` |
| 发布 | `release/{version}` | `release/5.7.0` |
| 热修复 | `hotfix/{version}-{desc}` | `hotfix/5.7.1-login-fix` |

## 提交示例

```
feat(admin): 新增会员积分管理页面
fix(api): 修复会员登录验证码校验失败问题
refactor(server): 重构菜单服务的查询逻辑
chore(core): 升级 webman 框架到 2.2
types(admin): 补充会员模块类型定义
release: v5.7.0
```

## 检查清单

- [ ] 提交信息是否符合 `<type>(<scope>): <subject>` 格式
- [ ] type 是否在允许的枚举值内
- [ ] scope 是否在允许的枚举值内
- [ ] header 长度是否超过 108 字符
- [ ] 分支命名是否遵循规范
