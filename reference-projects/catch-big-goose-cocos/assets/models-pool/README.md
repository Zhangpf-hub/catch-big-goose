# 模型候选池（不打包）

放置**暂未用于任何主题**的可用模型。

## 为什么不放在 resources/

`assets/resources/` 是 Cocos 的全量打包目录——放进去的资源不管有没有被引用
都会打进包体。这几个模型当前没有任何 `LevelConfig.THEMES` 的 family 引用它们，
留在 resources/ 里就是纯浪费（约 250KB 构建体积）。

放在 `assets/` 下的普通目录则不会打包（未被场景/预制体引用的资源会被构建剔除）。

## 当前池内模型

| id | 说明 | 备注 |
|---|---|---|
| `mile` | 弥勒 | 造型辨识度好，是下个古玩类主题的首选 |
| `yushi` | 玉石簇 | 深绿翡翠色，同上 |
| `pingankou` | 平安扣 | **不建议使用**：饱和度 0.02，与干扰物 `rock`（0.01）同为无彩灰，堆里易误拿 |

## 启用某个模型

1. 把 `<id>.glb` 与 `<id>.glb.meta` 一起移回 `assets/resources/models/`
2. 加进 `LevelConfig.ts` 里对应主题的 `family`
3. 图标：`assets/resources/icons/<id>.png` 仍在原处，无需处理
4. 跑一遍三关围栏回归确认包围盒正常（见 PLAN.md 的构建与自测一节）

移回前先按实际显示尺寸（物件约 90px）确认贴图分辨率，别直接用 1024²。
