# 关卡 HUD 精简与图片数字

日期：2026-10-25。工程：projects/catch-big-goose-unity；Unity 2022.3.62f3。

## 最终行为

- 顶部只保留居中的时间卡片，移除关卡名、得分、连击、消除数、百分比及进度条。
- 移除性能与摇动诊断的画面文字；诊断采样与日志接口保留，暂停菜单移除性能数据入口。
- 沿用上一轮移除摇一摇测试按钮的修改。
- 时间和移出、凑齐、打乱右上角的数量改用同一套生成的金色图片数字；数量使用现有蓝色按钮素材做角标。
- 数字包含 0–9、冒号、无穷符号。支持零、多位数量、普通倒计时、不限时，以及最后 15 秒的橙红提示。图片不参与点击拦截。

## 资源及实现

- 最终完整图集：[golden-digits-v1.png](../../projects/catch-big-goose-unity/Assets/Resources/Textures/hud-numbers/golden-digits-v1.png)。原图保留完整 alpha；切片由 GooseAssetImporter 的 Sprite 导入矩形完成。
- GooseSpriteNumber 复用一个图集与预建 Image，不再用动态 Text 绘制时间或数量；多位数自动按宽度缩放。
- 普通关卡、参考试玩和鸭子评审共用精简 HUD；实际得分和关卡规则仍按原逻辑运算。

## 验证

- npm run check：41/41 Passed。
- npm run structure:check：43 项通过，441 个文档链接无新增损坏（报告新增前运行）。
- 原生运行时验收：28 项通过，无错误，验收 JSON 位于 work/gameplay-hud-20261025/runtime/acceptance.json。
- 实际图像检查：450×844、360×640、390×844（模拟顶部 88、底部 34 的安全区）；均无数量裁切、残留进度文案或测试按钮。
- 数量测试夹具分别设置 0/2/5 和 1/3/12，仅供截图与更新验证，不改存档或正式关卡道具配置。
- 倒计时低时长和不限时分别保存 hud-low-time.png 与 hud-unlimited.png。
- 所有原生 QA 运行前执行 fix-player-network.ps1，保持本地 PlayerConnection；未申请防火墙权限。
- Windows 构建日志：work/gameplay-hud-20261025/qa-build.log 与 release-build.log。微信导出未由本次操作更新。

## 生图记录

使用内置 image_gen 工具，未使用 CLI/API 回退。

首轮提示词：

Use case: stylized-concept. Asset type: production sprite atlas for a cheerful Chinese casual match-three mobile game called Catch Big Goose. Create one transparent sprite sheet of chunky glossy cartoon numerals. Strong sunny golden yellow to tangerine gradient faces, soft cream specular highlight top-left, thin deep cocoa brown outline immediately around the face, thick ivory sticker outline, subtle brown bottom extrusion. Fits polished yellow rounded game buttons and warm illustrated rural courtyard art. High contrast saturated colors, round heavy playful typography, excellent legibility at 24 pixels. Exact layout: uniform 4 columns by 3 rows, 12 equal cells, no grid visible, each glyph centered inside its own cell with generous transparent padding, same cap height, same baseline, no overlapping. First row exact glyphs: 0 1 2 3. Second row: 4 5 6 7. Third row: 8 9 : ∞. Each cell contains exactly ONE glyph, and no other objects. Colon two vertically stacked circular dots, infinity horizontal figure eight symbol. Straight-on flat UI asset, no perspective, no background or boxes, no other text, no drop shadow extending beyond the glyph. Output canvas aspect ratio 4:3, use real transparent alpha.

第二轮以首轮图为编辑输入，保留图形、布局和色彩，要求清理透明区杂点并统一留白，输出最终透明图集。完整编辑提示词：

Edit target: this production sprite atlas. Preserve the exact twelve golden glyph designs, their sequence 0 1 2 3 / 4 5 6 7 / 8 9 : ∞ in a 4 columns by 3 rows regular grid. CRITICAL CLEANUP: remove ALL stray tiny white/colored flecks and grunge from between the glyphs, make outside of each solid ivory outline absolutely empty transparent alpha zero. Keep the outside outline smooth and clean, no ragged or speckled edges at all. Make every glyph fit inside its own equal grid cell with 12% clear padding on all sides so no glyph touches canvas edge or another cell. Uniform baseline and cap height for digits. Canvas 1536x1152 exact aspect 4:3. Each cell centered at x 192,576,960,1344 and y 192,576,960 from top. Transparent background, NO TEXT other than the 12 single glyphs, NO grid or cells visible. Polished clean game UI asset export.

最终工具实际输出为 1448×1086；导入切片按实际尺寸定位。最终样式为金黄至橙色渐变、深棕轮廓和奶油白描边，与项目暖色卡通按钮对齐。

