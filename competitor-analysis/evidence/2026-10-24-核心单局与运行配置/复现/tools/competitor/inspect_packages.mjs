// Local cache format research. Does not execute extracted scripts or modify the cache.
// Container envelope reference: https://github.com/BlackTrace/pc_wxapkg_decrypt
import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { basename, resolve, join } from 'node:path';
import { pbkdf2Sync, createDecipheriv, createHash } from 'node:crypto';
import { brotliDecompressSync } from 'node:zlib';

const [source, destination, appId] = process.argv.slice(2);
if (!source || !destination || !/^wx[0-9a-f]{16}$/.test(appId)) throw Error('Usage: node inspect_packages.mjs PACKAGE_DIR OUTPUT_DIR APPID');
const output = resolve(destination);
mkdirSync(output, { recursive: true });
const reports = [];
function packages(dir, prefix = '') {
  return readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const path = join(prefix, entry.name);
    return entry.isDirectory() ? packages(join(dir, entry.name), path) : entry.name.endsWith('.wxapkg') ? [path] : [];
  });
}
for (const name of packages(source)) {
  const original = readFileSync(join(source, name));
  let data = original;
  if (data.subarray(0, 6).toString() === 'V1MMWX') {
    const key = pbkdf2Sync(appId, 'saltiest', 1000, 32, 'sha1');
    const cipher = createDecipheriv('aes-256-cbc', key, Buffer.from('the iv: 16 bytes'));
    cipher.setAutoPadding(false);
    const first = Buffer.concat([cipher.update(data.subarray(6, 1030)), cipher.final()]).subarray(0, 1023);
    const rest = data.subarray(1030).map(b => b ^ appId.charCodeAt(appId.length - 2));
    data = Buffer.concat([first, rest]);
  }
  if (data[0] !== 0xbe || data[13] !== 0xed) throw Error(`Unsupported package header: ${name}`);
  const count = data.readUInt32BE(14);
  if (count > 10000) throw Error('Invalid file count');
  let position = 18;
  const entries = [];
  const folder = join(output, basename(name, '.wxapkg'));
  mkdirSync(folder, { recursive: true });
  for (let i = 0; i < count; i++) {
    const length = data.readUInt32BE(position); position += 4;
    const file = data.subarray(position, position + length).toString('utf8'); position += length;
    const start = data.readUInt32BE(position), size = data.readUInt32BE(position + 4); position += 8;
    if (start + size > data.length) throw Error('Out-of-range package entry');
    // Flat, indexed output; archive paths never become writable paths.
    const target = `${i}-${basename(file).replace(/[^a-zA-Z0-9_.-]/g, '_')}`;
    const blob = data.subarray(start, start + size);
    writeFileSync(join(folder, target), blob);
    const entry = { file, size, extracted: basename(name, '.wxapkg') + '/' + target, sha256: createHash('sha256').update(blob).digest('hex') };
    if (/wasm|\.br$/i.test(file)) {
      let raw = blob;
      if (raw.subarray(0, 4).toString('hex') !== '0061736d') {
        try { raw = brotliDecompressSync(blob); } catch { raw = null; }
      }
      if (raw?.subarray(0, 4).toString('hex') === '0061736d') {
        writeFileSync(join(folder, target + '.decoded.wasm'), raw);
        entry.wasm = { bytes: raw.length, sha256: createHash('sha256').update(raw).digest('hex'), file: entry.extracted + '.decoded.wasm' };
      }
    }
    entries.push(entry);
  }
  reports.push({ package: name, bytes: original.length, sourceSha256: createHash('sha256').update(original).digest('hex'), entries });
}
writeFileSync(join(output, 'packages.json'), JSON.stringify(reports, null, 2));
console.log(JSON.stringify(reports.map(p => ({ package: p.package, entries: p.entries.map(e => ({file:e.file,size:e.size,wasm:e.wasm})) })), null, 2));
