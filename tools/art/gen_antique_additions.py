"""为「古玩铺」补齐玉玺与如意两个原创程序化模型及槽位图标。"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_farm_theme as base


JADE = (0.08, 0.48, 0.34, 1)
PALE_JADE = (0.42, 0.78, 0.62, 1)
GOLD = (0.73, 0.45, 0.10, 1)
VERMILION = (0.68, 0.035, 0.025, 1)


def yuxi():
    jade = base.material("yuxi_jade", JADE, 0.30)
    gold = base.material("yuxi_gold", GOLD, 0.35)
    red = base.material("yuxi_vermilion", VERMILION, 0.48)
    parts = [
        base.cube("seal_base", (0, 0, -0.30), (0.72, 0.72, 0.34), jade, 0.07),
        base.cube("gold_band", (0, 0, 0.03), (0.77, 0.77, 0.08), gold, 0.045),
        base.cube("seal_top", (0, 0, 0.25), (0.55, 0.55, 0.18), jade, 0.12),
        base.sphere("knob", (0, 0, 0.63), (0.28, 0.25, 0.24), gold, 18, 10),
    ]
    # 朱红印面露出一圈，俯视密堆里与灰石头、绿色玉件都能明显分开。
    parts.append(base.cube("seal_face", (0, 0, -0.66), (0.58, 0.58, 0.045), red, 0.035))
    return base.join(parts, "yuxi")


def ruyi():
    pale = base.material("ruyi_jade", PALE_JADE, 0.28)
    gold = base.material("ruyi_gold", GOLD, 0.36)
    red = base.material("ruyi_gem", VERMILION, 0.28)
    parts = []
    # 用连续椭球构成略弯的长柄；每段重叠，导出后是稳定的单网格且不依赖曲线修改器。
    path = [(-0.72, -0.36), (-0.48, -0.19), (-0.23, -0.08),
            (0.03, 0.00), (0.27, 0.12), (0.46, 0.31)]
    for i, (x, y) in enumerate(path):
        angle = math.radians(18 if i < 3 else 32)
        seg = base.sphere("handle", (x, y, 0), (0.28, 0.14, 0.13), pale, 14, 8)
        seg.rotation_euler = (0, 0, angle)
        parts.append(seg)
    # 如意头用三瓣云形 + 中央朱砂宝珠，一眼区别于手串、玉镯等环件。
    for a in (math.radians(30), math.radians(150), math.radians(270)):
        parts.append(base.sphere("cloud", (0.63 + math.cos(a) * 0.25,
                                             0.42 + math.sin(a) * 0.25, 0.02),
                                 (0.30, 0.22, 0.16), pale, 16, 10))
    parts.append(base.sphere("gem", (0.63, 0.42, 0.17), (0.16, 0.16, 0.12), red, 14, 8))
    parts.append(base.sphere("end_cap", (-0.91, -0.49, 0), (0.19, 0.18, 0.15), gold, 14, 8))
    return base.join(parts, "ruyi")


if __name__ == "__main__":
    for model_name, builder in [("yuxi", yuxi), ("ruyi", ruyi)]:
        base.wipe()
        model = builder()
        base.export_glb(model, model_name)
        base.render_icon(model, model_name)
    print("ALL DONE", base.MODELS, base.ICONS)
