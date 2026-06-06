---
name: madong-frontend-apps-store
description: 前端状态管理规范，Pinia Store
globs:
  - "apps/**/src/store/**/*.ts"
---

## 文件位置

```
apps/{app}/src/store/
├── index.ts                     # Store 导出
├── auth.ts                      # 认证状态
└── modules/
    ├── dict.ts                  # 字典缓存
    ├── notify.ts                # 消息通知（admin 特有）
    └── site-config.ts           # 系统配置
```

## 认证 Store (auth.ts)

```typescript
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const token = ref('');
  const userInfo = ref<UserInfo | null>(null);

  async function authLogin(params: LoginParams) {
    // 登录流程：获取 token → 用户信息 → 权限码
  }

  async function logout() {
    // 清除 token / 用户信息
  }

  return { token, userInfo, authLogin, logout };
});
```

## 字典 Store (modules/dict.ts)

```typescript
export const useDictStore = defineStore('dict', () => {
  const dictMap = ref<Record<string, DictItem[]>>({});

  async function getDict(type: string): Promise<DictItem[]> {
    if (dictMap.value[type]) return dictMap.value[type];
    const data = await getDictData(type);
    dictMap.value[type] = data;
    return data;
  }

  return { dictMap, getDict };
});
```

## Store 模板

```typescript
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const use{Name}Store = defineStore('{name}', () => {
  // 状态
  const count = ref(0);

  // 计算属性
  const doubleCount = computed(() => count.value * 2);

  // 动作
  function increment() {
    count.value++;
  }

  return { count, doubleCount, increment };
});
```

## admin vs platform 差异

| Store | admin | platform |
|-------|-------|----------|
| `auth.ts` | 含多租户切换逻辑 | 不含多租户 |
| `notify.ts` | 有（WebSocket Push） | 无 |
| `dict.ts` | 有 | 有 |
| `site-config.ts` | 有 | 有 |

## 关键约定

- 使用 Pinia 的 setup 语法（`defineStore('{name}', () => { ... })`）
- Store 命名：`use{Name}Store`，内部名称：`'{name}'`
- 状态用 `ref()` / `reactive()`，计算属性用 `computed()`，动作用普通函数
- 字典 Store 做了缓存，同一字典只请求一次
- 认证 Store 处理登录/登出/用户信息/权限码

## 检查清单

- [ ] Store 是否使用 setup 语法（composition API）
- [ ] Store 名称是否与其他 Store 不冲突
- [ ] 异步操作是否正确处理了 loading 状态
- [ ] 字典是否使用了缓存机制
