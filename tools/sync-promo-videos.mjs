import { copyFileSync, existsSync, mkdirSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { root } from './cocos-paths.mjs';

export const promoFiles = ['Darkchaser-Battletide.mp4', 'Skycore-Reboot.f5800.mp4'];

export function syncPromoVideos(destination) {
  mkdirSync(join(destination, 'video'), { recursive: true });
  for (const name of promoFiles) {
    const source = join(root, 'source-assets/videos', name);
    if (!existsSync(source) || statSync(source).size === 0) throw new Error(`宣传片缺失：${source}`);
    copyFileSync(source, join(destination, 'video', name));
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  syncPromoVideos(join(root, 'reference-projects/catch-big-goose-cocos/preview-template'));
  syncPromoVideos(join(root, 'reference-projects/catch-big-goose-cocos/build-templates/web-mobile'));
  const output = join(root, 'reference-projects/catch-big-goose-cocos/build/web-mobile');
  if (existsSync(output)) syncPromoVideos(output);
  console.log('已同步两支宣传片到编辑器预览、发布模板和现有 H5 产物');
}
