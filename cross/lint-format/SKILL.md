---
name: madong-cross-lint-format
description: Lint/Format 工具链规范，oxfmt + oxlint + eslint + stylelint + lefthook
globs:
  - "**/*.ts"
  - "**/*.vue"
  - "**/*.js"
  - "**/*.scss"
  - "**/*.css"
---

## 工具链概览

| 工具 | 替代 | 配置位置 | 说明 |
|------|------|----------|------|
| **oxfmt** | prettier | `frontend/oxfmt.config.ts` | Rust 高性能格式化 |
| **oxlint** | eslint(部分) | `frontend/oxlint.config.ts` | Rust 高性能 Lint |
| **eslint** | - | `frontend/eslint.config.mjs` | Flat Config 格式，引用 `@vben/eslint-config` |
| **stylelint** | - | `frontend/stylelint.config.mjs` | 引用 `@vben/stylelint-config` |
| **lefthook** | husky | `frontend/lefthook.yml` | Git hooks 管理 |

## 格式化工具

### oxfmt（替代 prettier）

```bash
# 格式化暂存文件（pre-commit 自动执行）
pnpm oxfmt {staged_files}

# 全量格式化
pnpm format
```

支持的文件类型：`*.ts` / `*.vue` / `*.js` / `*.json` / `*.md` / `*.scss` / `*.css`

## Lint 工具

### oxlint（Rust 高性能 Lint）

```bash
# 检查并自动修复暂存文件
pnpm oxlint --fix {staged_files}
```

### eslint（Flat Config）

```bash
# 检查并自动修复暂存文件
pnpm eslint --cache --fix {staged_files}

# 全量检查
pnpm lint

# 全量格式化 + 修复
pnpm format
```

配置文件使用 ESLint Flat Config 格式（`eslint.config.mjs`），引用 `@vben/eslint-config`。

### stylelint

```bash
# 检查并修复样式文件
pnpm stylelint --fix --allow-empty-input {staged_files}
```

## Lint 流程（按文件类型）

### *.vue 文件

```
oxfmt → oxlint --fix → eslint --cache --fix → stylelint --fix
```

### *.{js,jsx,ts,tsx} 文件

```
oxfmt → oxlint --fix → eslint --cache --fix
```

### *.{scss,less,styl,html,vue,css} 文件

```
oxfmt → stylelint --fix
```

### *.md 文件

```
oxfmt
```

### *.json 文件

```
oxfmt
```

## 手动命令

```bash
# 全量 Lint
pnpm lint

# 全量格式化
pnpm format

# 综合检查（循环依赖 + 依赖检查 + 类型检查 + 拼写检查）
pnpm check

# 交互式提交（自动触发 commitlint）
pnpm commit
```

## 安装 hooks

```bash
# 安装 lefthook git hooks（Windows 兼容）
pnpm prepare
# 实际执行：is-ci || (where git >nul 2>&1 && pnpm exec lefthook install) || true
```

## 关键约定

- 使用 oxfmt 替代 prettier（Rust 高性能格式化）
- 使用 oxlint 作为第一层 Lint（快速捕获常见问题），eslint 作为第二层（复杂规则）
- eslint 使用 Flat Config 格式（`eslint.config.mjs`），非传统 `.eslintrc`
- 所有 Lint 在 pre-commit 时通过 lefthook 并行执行
- 使用 lefthook 替代 husky 管理 Git hooks
- 不使用 lint-staged，lint 逻辑直接在 lefthook.yml 中配置

## 检查清单

- [ ] 是否使用 oxfmt 而非 prettier
- [ ] 是否使用 lefthook 而非 husky
- [ ] eslint 配置是否使用 Flat Config 格式
- [ ] pre-commit 钩子是否正确配置
