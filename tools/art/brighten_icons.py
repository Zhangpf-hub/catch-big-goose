"""槽位图标提亮：对 icons/*.png 的 RGB 做 gamma 提亮 + 轻微线性增益，保留 alpha。

Workbench(STUDIO) 渲染出的图标偏哑光、整体偏暗，进游戏后压在格子里更显暗。
这里做纯后处理提亮，不用重跑 Blender。gamma < 1 对中暗部提升明显，
GAIN 做小幅线性抬亮，最后 clip 到 255 防溢出。alpha 通道原样保留。

用法：
    python tools/art/brighten_icons.py            # 提亮全部图标
    python tools/art/brighten_icons.py apple cherry  # 只提亮指定图标
可调 GAMMA / GAIN 两个参数控制强度。
"""
import os
import sys
import numpy as np
from PIL import Image

ICONS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\icons"
BACKUP = os.path.join(os.environ.get("TEMP", "."), "icons_backup")

GAMMA = 0.60   # 越小越亮（暗部提升更强），1.0 = 不变
GAIN = 1.12    # 线性增益，整体再抬一点亮度


def brighten(path: str):
    img = Image.open(path).convert("RGBA")
    arr = np.asarray(img, dtype=np.float32)
    rgb = arr[..., :3] / 255.0
    rgb = np.power(rgb, GAMMA) * GAIN          # gamma 提亮 + 线性增益
    arr[..., :3] = np.clip(rgb, 0.0, 1.0) * 255.0
    Image.fromarray(arr.astype(np.uint8), "RGBA").save(path)


def main():
    os.makedirs(BACKUP, exist_ok=True)
    names = sys.argv[1:]
    files = [f for f in os.listdir(ICONS) if f.endswith(".png")]
    if names:
        files = [f for f in files if f[:-4] in names]
    for f in files:
        src = os.path.join(ICONS, f)
        bak = os.path.join(BACKUP, f)
        if not os.path.exists(bak):        # 只备份一次原图，避免二次运行覆盖备份
            Image.open(src).save(bak)
        brighten(src)
        print("BRIGHTEN", f)
    print(f"DONE gamma={GAMMA} gain={GAIN}  backup={BACKUP}")


if __name__ == "__main__":
    main()
