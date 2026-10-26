"""Make actual-size icons and a four-view review sheet after Blender generation."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

folder = Path(__file__).resolve().parents[2] / 'source-assets/models/candidates/competitor-alignment-corn'
image = Image.open(folder / 'three-quarter.png').convert('RGBA')
for size, name in [(192, 'corn-icon.png'), (64, 'corn-64.png')]:
    image.resize((size, size), Image.Resampling.LANCZOS).save(folder / name)
sheet = Image.new('RGB', (1024, 620), '#f4efe5')
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 22)
small = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 16)
draw.text((20, 14), '自有玉米候选 · 792 三角形 / 1 材质 / 512 贴图', fill='#243744', font=font)
for i, (name, label) in enumerate([('three-quarter', '三分之四'), ('front', '正视'), ('back', '背视'), ('top', '俯视')]):
    view = Image.open(folder / (name + '.png')).convert('RGBA').resize((256, 256))
    sheet.paste(view, (i * 256, 52), view)
    draw.text((i * 256 + 20, 310), label, fill='#243744', font=font)
for i, (name, label) in enumerate([('corn-icon.png', '192px 图标'), ('corn-64.png', '64px 实际尺寸')]):
    icon = Image.open(folder / name).convert('RGBA')
    x = 35 + i * 270
    sheet.paste(icon, (x, 365), icon)
    draw.text((x, 560), label, fill='#243744', font=small)
draw.text((550, 390), '原创几何与程序绘制贴图\n未使用竞品模型或贴图\n候选状态：尚未替换正式资源\n物理管线、Unity 导入和实机关卡待验收', fill='#243744', font=small, spacing=14)
sheet.save(folder / 'review.jpg', quality=93)
