# 第三方模型来源与许可

从 [Poly Pizza](https://poly.pizza) 获取的模型：

| 游戏内 id | 原模型 | 作者 | 许可 | 来源 |
|---|---|---|---|---|
| `yuanbao`（招财钱袋） | Gold Bag | Quaternius | CC0（公有领域） | https://poly.pizza/m/vFFblhnHtb |
| `baoshi`（翡翠宝石） | Gem | Quaternius | CC0（公有领域） | https://poly.pizza/m/kbgiCMzdxg |
| `yushi`（玉石簇） | Big Crystal | Quaternius | CC0（公有领域） | https://poly.pizza/m/pf5lzmgr2J |

玉玺 `yuxi` 的狮钮基于 Sketchfab 扫描模型：

| 游戏内 id | 原模型 | 作者 | 许可 | 来源 |
|---|---|---|---|---|
| `yuxi`（玉玺狮钮） | Chinese guardian lion | rvscanners | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) | https://sketchfab.com/3d-models/chinese-guardian-lion-afdb632cc23f4c0c9bbaa1100010039f |

本项目对狮钮做了分片体素融合、移动端减面、尺度归一化、暖玉与古金材质重建，并与原创
玉玺印台、朱砂回纹组合。原始下载件未纳入版本库；处理脚本与完整署名见
`tools/art/prepare_yuxi_guardian_source.py` 和
`source-assets/models/sources/yuxi/rvscanners-chinese-guardian-lion/ATTRIBUTION.md`。

## ⚠️ 注意

- CC0 模型（Quaternius）：可自由使用，无需署名，无附加限制。
- **`jingling`（精灵球）已于 2026-07-29 移除**：该造型属任天堂/宝可梦商标与知识产权，
  原计划仅用于个人学习用途的 MVP。转做 H5 并准备对外发布后已删除模型与图标，
  且 `resources/` 是全量打包目录，留着即使不用也会进包体。**不要再加回来。**

导入后均经处理：合并网格、归一化到最大边 = 1.0、纯色不透明材质（翡翠绿 / 金色），
以贴合本作美术。原始下载件未纳入版本库。

## 本项目原创程序化模型

池塘农场的 `carrot`、`corn`、`eggplant`、`frog`、`pumpkin`、`mushroom`、`koi`、
`lotus`、`duck` 与 `basket_farm` 均由 `tools/art/gen_farm_theme.py` 在 Blender 中生成，
不依赖第三方模型或贴图。完整设计与复现记录见 `design/farm-theme/README.md`。

甜品小镇的 `cupcake`、`donut`、`icecream`、`macaron`、`cookie`、`cake_slice`、
`candy`、`pudding`、`croissant` 与 `tray_dessert` 同样是原创程序化模型，生成脚本为
`tools/art/gen_dessert_theme.py`，设计记录见 `design/dessert-theme/README.md`。

古玩铺的 `ruyi` 由 `tools/art/gen_antique_additions.py` 生成；`yuxi` 的印台与装饰由
`tools/art/gen_antique_theme_v2.py` 生成，狮钮来源和修改说明见上文。设计记录见
`design/antique-additions/README.md`。
