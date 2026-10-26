#!/usr/bin/env bash
# Tripo 出的 GLB 压缩流水线（减面 + 压贴图）。
#
# 背景：Tripo 导出的容器模型约 50 万三角面 / 15-17MB，既撑爆微信小游戏 4MB 主包，
# 手机运行时也掉帧。浅托盘/浅碗这类造型 ~10k 面足够，细节由法线贴图承担。
# 实测：17.3MB → 787KB（-95%），包围盒比例不变，不影响 CONTAINER_SPAN 缩放逻辑。
#
# 依赖：npm install -g @gltf-transform/cli
#
# 用法：
#   tools/art/compress_glb.sh <输入.glb> [输出.glb] [面数比例] [贴图边长]
# 例：
#   tools/art/compress_glb.sh "~/Downloads/rattan tray.glb" reference-projects/catch-big-goose-cocos/assets/resources/models/tray_picnic.glb
#
set -euo pipefail

IN="${1:?用法: compress_glb.sh <输入.glb> [输出.glb] [ratio] [texsize]}"
OUT="${2:-}"
RATIO="${3:-0.02}"     # 目标面数占比；0.02 ≈ 50万面 → 1万面
TEX="${4:-1024}"       # 贴图最大边长

if [ -z "$OUT" ]; then
  OUT="${IN%.glb}_min.glb"
fi

command -v gltf-transform >/dev/null 2>&1 || {
  echo "缺少 gltf-transform，先执行： npm install -g @gltf-transform/cli" >&2
  exit 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> 减面 (ratio=$RATIO)"
gltf-transform simplify "$IN" "$TMP/s.glb" --ratio "$RATIO" --error 0.01

echo "==> 压贴图 (max ${TEX}px)"
gltf-transform resize "$TMP/s.glb" "$OUT" --width "$TEX" --height "$TEX"

before=$(wc -c < "$IN")
after=$(wc -c < "$OUT")
echo "==> 完成: $(( before / 1024 ))KB → $(( after / 1024 ))KB  (-$(( 100 - after * 100 / before ))%)"
echo "    $OUT"
echo
echo "提醒：放进 reference-projects/catch-big-goose-cocos/assets/resources/models/ 后，文件名不要带空格；"
echo "      在 SceneSkin 对应皮肤上设 containerModel: '<文件名去掉.glb>'。"
