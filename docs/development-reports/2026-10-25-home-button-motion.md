# 主界面按钮动画流畅度优化

日期：2026-10-25。源工程：projects/catch-big-goose-unity，Unity 2022.3.62f3。

## 原因与修改

1. 主界面沿用 Canvas 的整像素对齐。按钮虽逐帧改变缩放，但 UGUI 的 GetPixelAdjustedRect 把图形边缘吸附到整像素，实际呈现大量停留帧和突然的 1 像素跳动。仅在主界面关闭 pixelPerfect，进入游戏恢复原有设置。
2. 移动配置和微信 SDK 原先统一请求 30 FPS。现在主界面请求 60 FPS，进入关卡按移动端 30／桌面 60 的既有预算运行，回到主界面恢复 60。微信初始化、前后台切换及画面状态改变同步更新 SDK 帧率，避免仅修改 Unity 参数仍被 SDK 限制。
3. 旧跳跃曲线的起落速度突然变化；改成两端速度为零的余弦包络，挤压形变也平滑收尾。没有跳跃的标题、设置按钮不再附带周期挤压。
4. 按压弹簧由逐步欧拉积分改为阻尼振子的解析积分，避免 30／60／120 帧和不均匀帧间隔产生不同的回弹节奏。保留固定点击区域、视觉层变形和松手星星反馈。

修改文件：GooseCandyMotion.cs、GooseHud.cs、GooseHud.Story.cs、GooseRuntimePerformance.cs、GooseWeChatPlatform.cs。未更改图片素材或关卡物理参数。

## 同机对比

真实原生图形运行，450×844，每阶段采样 6 秒，首次主界面与进关返回后各一次。截图保存发生在采样区间之外。完整结果在 work/home-motion-20261025/ 的 baseline-desktop、baseline-mobile、optimized-desktop、optimized-mobile 目录。

下表为首次主界面样本：

| 配置 | 修改前帧率 | 修改后帧率 | 修改前边缘停留采样占比 | 修改后边缘停留采样占比 | 修改后 P95 帧时 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 桌面 | 59.99 FPS | 60.00 FPS | 78.67% | 2.76% | 16.67 ms |
| 移动配置的桌面验证 | 30.00 FPS | 59.72 FPS | 68.13% | 3.06% | 16.67 ms |

边缘停留定义为 CTA 图片经过 UGUI 像素校正后的左下顶点，相邻帧屏幕位移小于 0.01 像素。它用于对比动画的像素步进，不等同于整幅画面的重复帧率；自然运动极值附近也会有少量停留采样。

桌面首次样本最大边缘步长由 1.414 px 降到 0.477 px。返回主界面后的帧率分别为 60.00 和 59.99 FPS，停留占比为 2.49% 和 2.77%。优化后的四段采样均无 GC0 回收、无超过 50 ms 的帧；移动配置首次样本有两帧超过 25 ms。

以上为 Windows 真实图形运行和移动参数模拟，不能视为微信真机帧率。微信源代码已同步策略；本轮没有重新导出微信包。

## 验证与交付

- npm run check：43/43 Passed，包含跨帧率弹簧响应、不均匀帧间隔、起落端点连续性检查。
- 原生对比验收：两个优化配置各 14 项检查通过，包括真实主界面、按下形变、固定点击区域、一次松手反馈、进关与回到主页、帧预算与物理步长保留。
- 基线源码副本位于 work/home-motion-20261025/baseline-source；历史参考项目和冻结证据未修改。
- 构建使用现有 GooseUiQualityBuild 及 GoosePlayerNetworkPolicy；运行前执行 fix-player-network.ps1，保持本地 PlayerConnection。
- Windows 正式包：projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe；构建日志 work/home-motion-20261025/release-build.log。
- 新增 QA 入口：-homeMotionQa -homeMotionOutput <输出目录>；附加 -gooseMobileProfile 验证移动配置。该工具仅在编辑器或非 WebGL 开发包中编译。
