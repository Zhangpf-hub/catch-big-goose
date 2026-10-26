# 货车上方通道与简化文字

日期：2026-10-26。

货车移到计时卡下、三消相机区域上的独立通道。可点击车身整体位于三消视口外，经过时不占用物堆的点击位置。短屏从开局就为通道留出空间，出车时不临时挪动物堆；长屏保持物堆按原宽度显示。

车身只显示“道具甩卖”，字号从 32 提升为 48，删除“看视频／三种各一个”等小字。奖励图标的出发位置同步跟随新的货车位置。录像不再叠加“演示”“跳过等待时间”“广告完整播放”等提示。

## 验收

专用运行验收 37 项通过，覆盖 360×640、390×844、430×932 以及模拟刘海安全区。逐一检查货车点击范围完全在三消视口上方、在计时卡下方、仅有一个放大标题、没有录制提示；货车显示期间使用正式按下／松开指针流程点选真实物品，验证物品正常入槽且游戏继续。

- [实际录像](../../work/truck-upper-lane-20261026/runtime/truck-upper-lane-demo.mp4)
- [390×844](../../work/truck-upper-lane-20261026/runtime/truck-upper-390x844.png) · [360×640](../../work/truck-upper-lane-20261026/runtime/truck-upper-360x640.png) · [430×932](../../work/truck-upper-lane-20261026/runtime/truck-upper-430x932.png) · [刘海安全区](../../work/truck-upper-lane-20261026/runtime/truck-upper-safe-area.png)
- [运行检查](../../work/truck-upper-lane-20261026/runtime/acceptance.json) · [编辑模式结果](../../work/truck-upper-lane-20261026/editmode-results.xml)

本轮全量编辑模式结果为 60/61；未通过项为旧模型尺寸比例检查 `RelativeSizesSeparateLargeSilhouettesFromSmallItems`，读取当前尺寸表得到比例 1 而旧断言要求至少 2，与货车位置和字体无关，本轮未改动该尺寸表或断言。录像由实际 Windows 玩家画面采集，不叠加开发说明；等待出车仍由开发参数提前触发，正式关卡的时点和概率保持原规则。

Windows 当前玩家已重建。微信使用固定源码副本完成 WebGL 编译并更新到 `builds/catch-big-goose-wechat`；逐文件核对当前导出，18 项包检查及 61 个 JS 文件语法检查通过，实际打包 26.05 MiB。旧压缩资源保留并逐项排除打包。微信视频桥接 15 项检查通过；未重复播放广告或宣称手机真机验收。[交付清单](../../work/truck-upper-lane-20261026/delivery.json)
