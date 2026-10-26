#!/usr/bin/env node
/**
 * 图生 3D 常会把参考图里的多角度小样也生成到同一网格。这里按三角面共享顶点的
 * 连通关系，只保留面数最大的主体；不改材质、UV 或顶点位置，后续再交给减面流程处理。
 */
const path = require('node:path');
const { NodeIO } = require('/Users/xmly/.local/share/fnm/node-versions/v20.20.0/installation/lib/node_modules/@gltf-transform/cli/node_modules/@gltf-transform/core');

const [input, output, rankText = '0'] = process.argv.slice(2);
if (!input || !output) throw new Error('用法: keep-largest-glb-component.cjs <输入.glb> <输出.glb>');
const componentRank = Number.parseInt(rankText, 10);
if (!Number.isInteger(componentRank) || componentRank < 0) throw new Error('组件序号必须是非负整数');

class DisjointSet {
  constructor(size) { this.parent = Int32Array.from({ length: size }, (_, i) => i); }
  find(x) { while (this.parent[x] !== x) { this.parent[x] = this.parent[this.parent[x]]; x = this.parent[x]; } return x; }
  union(a, b) { a = this.find(a); b = this.find(b); if (a !== b) this.parent[b] = a; }
}

async function main() {
  const io = new NodeIO();
  const doc = await io.read(input);
  let kept = 0;
  for (const mesh of doc.getRoot().listMeshes()) {
    for (const prim of mesh.listPrimitives()) {
      const indices = prim.getIndices()?.getArray();
      if (!indices || indices.length < 3) continue;
      const maxIndex = indices.reduce((max, value) => Math.max(max, value), 0);
      const set = new DisjointSet(maxIndex + 1);
      const positions = prim.getAttribute('POSITION')?.getArray();
      if (!positions) throw new Error('网格缺少 POSITION 属性');
      // GLB 会因 UV/法线硬边复制顶点；按坐标量化焊接，才能将同一纸杯的缝合面
      // 识别为一个组件，同时不把隔开的参考小样错误连在一起。
      const welded = new Map();
      for (let vertex = 0; vertex <= maxIndex; vertex++) {
        const offset = vertex * 3;
        const key = `${Math.round(positions[offset] * 1e5)},${Math.round(positions[offset + 1] * 1e5)},${Math.round(positions[offset + 2] * 1e5)}`;
        const previous = welded.get(key);
        if (previous === undefined) welded.set(key, vertex);
        else set.union(vertex, previous);
      }
      for (let i = 0; i < indices.length; i += 3) {
        set.union(indices[i], indices[i + 1]);
        set.union(indices[i], indices[i + 2]);
      }
      const triangles = new Map();
      for (let i = 0; i < indices.length; i += 3) {
        const root = set.find(indices[i]);
        triangles.set(root, (triangles.get(root) ?? 0) + 1);
      }
      const ordered = [...triangles.entries()].sort((a, b) => b[1] - a[1]);
      console.log(`components by triangle count: ${ordered.map(([, faces]) => faces).join(', ')}`);
      const [largest, count] = ordered[componentRank] ?? ordered[0];
      const filtered = new indices.constructor(indices.length);
      let cursor = 0;
      for (let i = 0; i < indices.length; i += 3) {
        if (set.find(indices[i]) !== largest) continue;
        filtered[cursor++] = indices[i]; filtered[cursor++] = indices[i + 1]; filtered[cursor++] = indices[i + 2];
      }
      prim.getIndices().setArray(filtered.slice(0, cursor));
      console.log(`${mesh.getName() || 'mesh'}: selected #${componentRank}, ${indices.length / 3} -> ${count} triangles, components=${triangles.size}`);
      kept += count;
    }
  }
  if (!kept) throw new Error('未找到可裁剪的三角网格');
  await io.write(output, doc);
}

main().catch(error => { console.error(error); process.exit(1); });
