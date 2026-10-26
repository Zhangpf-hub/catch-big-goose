#!/usr/bin/env node
import { closeSync, existsSync, lstatSync, mkdirSync, openSync, readFileSync, readdirSync, realpathSync, rmSync, statSync } from 'node:fs';
import { dirname, isAbsolute, join, relative, resolve } from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { findCreator, root } from './cocos-paths.mjs';
import { promoFiles, syncPromoVideos } from './sync-promo-videos.mjs';
import { inspectBuildLog } from './cocos-build-log.mjs';

const project = join(root, 'reference-projects/catch-big-goose-cocos');
const output = join(project, 'build/web-mobile');
const logPath = join(project, 'temp/web-mobile-build.log');
const normalize = path => process.platform === 'win32'
  ? resolve(path).toLowerCase() : resolve(path);

function projectProcesses() {
  const result = process.platform === 'win32'
    ? spawnSync('powershell.exe', ['-NoProfile', '-Command',
      'Get-CimInstance Win32_Process -Filter "name = \'CocosCreator.exe\'" | Select-Object -ExpandProperty CommandLine | ConvertTo-Json -Compress'],
    { encoding: 'utf8', windowsHide: true })
    : spawnSync('ps', ['-ax', '-o', 'command='], { encoding: 'utf8' });
  if (result.error || result.status !== 0) throw new Error('无法读取编辑器进程，不能确认构建前提。');
  let commands;
  if (process.platform === 'win32') {
    const value = JSON.parse(result.stdout.trim() || '[]');
    commands = Array.isArray(value) ? value : [value];
  } else commands = result.stdout.split('\n').filter(line => line.includes('CocosCreator'));
  const state = { editor: false, builder: false };
  for (const command of commands) {
    if (typeof command !== 'string') continue;
    const match = command.match(/(?:^|\s)--project(?:\s+|=)(?:"([^"]+)"|'([^']+)'|(\S+))/);
    if (!match || normalize(match[1] || match[2] || match[3]) !== normalize(project)) continue;
    if (/(?:^|\s)--build(?:\s|=)/.test(command)) state.builder = true;
    else state.editor = true;
  }
  return state;
}

function assertSafeOutput() {
  // 只允许清理本工程 build/web-mobile；检查真实路径，避免符号链接把清理引向工作区外。
  const base = realpathSync(project);
  for (const path of [dirname(output), output]) {
    if (!existsSync(path)) continue;
    const rel = relative(base, realpathSync(path));
    if (!rel || rel.startsWith('..') || isAbsolute(rel) || lstatSync(path).isSymbolicLink()) {
      throw new Error(`构建目标不安全，拒绝清理：${path}`);
    }
  }
  if (relative(project, output).replaceAll('\\', '/') !== 'build/web-mobile') {
    throw new Error(`构建输出路径异常：${output}`);
  }
}

function verifyOutput() {
  for (const file of ['index.html', 'jolt-glue.js', 'assets/main/index.js']) {
    if (!existsSync(join(output, file))) throw new Error(`构建产物缺少 ${file}`);
  }
  if (!readFileSync(join(output, 'assets/main/index.js'), 'utf8').includes('退出本局')) {
    throw new Error('脚本包为空壳，缺少玩法代码；请确认编辑器已打开本工程并完成导入。');
  }
  let bytes = 0;
  let videoBytes = 0;
  function walk(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) walk(path);
      else {
        if (entry.name.endsWith('.map')) throw new Error(`release 产物仍含 source map：${entry.name}`);
        const size = statSync(path).size;
        if (promoFiles.some(name => path === join(output, 'video', name))) videoBytes += size;
        else bytes += size;
      }
    }
  }
  walk(output);
  for (const name of promoFiles) {
    if (statSync(join(output, 'video', name)).size !== statSync(join(root, 'source-assets/videos', name)).size) {
      throw new Error(`宣传片发布不完整：${name}`);
    }
  }
  console.log(`宣传片 ${(videoBytes / 1024 / 1024).toFixed(2)} MiB，独立按需加载`);
  if (bytes > 20 * 1024 * 1024) throw new Error(`产物 ${(bytes / 1024 / 1024).toFixed(2)} MiB，超过 20 MiB 门禁。`);
  console.log(`✅ release/WASM 产物 ${(bytes / 1024 / 1024).toFixed(2)} MiB，脚本与 Jolt 完整，无 source map，MD5 关闭`);
}

try {
  const creator = findCreator();
  const processes = projectProcesses();
  if (processes.builder) throw new Error('本工程已有构建正在运行，请等待它完成。');
  // Windows 的两个 Creator 进程会争用 project.log 与 Chromium 缓存；使用独立 CLI 构建。
  // macOS 保留本工程已验证的前提：编辑器必须打开，避免缺少玩法代码的空壳包。
  if (process.platform === 'win32' && processes.editor) {
    throw new Error('Windows 构建前请保存并关闭本工程的 Creator 编辑器，避免日志和缓存文件锁冲突。');
  }
  if (process.platform !== 'win32' && !processes.editor) {
    throw new Error(`请先用 Cocos Creator 打开本工程并完成导入：${project}。未打开本工程可能生成空壳包。`);
  }
  assertSafeOutput();
  syncPromoVideos(join(project, 'preview-template'));
  syncPromoVideos(join(project, 'build-templates/web-mobile'));
  rmSync(output, { recursive: true, force: true });
  mkdirSync(dirname(logPath), { recursive: true });
  const fd = openSync(logPath, 'w');
  let status;
  try {
    console.log(`正在构建 web-mobile，日志：${logPath}`);
    status = await new Promise((resolveStatus, reject) => {
      const child = spawn(creator, ['--project', project, '--build',
        'platform=web-mobile;debug=false;sourceMaps=false;md5Cache=false;nativeCodeBundleMode=wasm;buildPath=project://build;outputName=web-mobile'],
      { cwd: root, windowsHide: true, stdio: ['ignore', fd, fd] });
      child.once('error', reject);
      child.once('close', resolveStatus);
    });
  } finally { closeSync(fd); }
  const log = readFileSync(logPath, 'utf8');
  if (!log.includes('build Task (web-mobile) Finished')) {
    throw new Error(`Cocos 构建未完成（退出码 ${status}）。\n${log.split(/\r?\n/).slice(-60).join('\n')}`);
  }
  const { errors, startupWarnings } = inspectBuildLog(log);
  if (startupWarnings.length) console.warn('⚠️ Creator 启动时在线资讯加载超时；继续校验已完成的本地构建。');
  if (errors.length) throw new Error(`构建日志包含错误（退出码 ${status}）：\n${errors.slice(-20).join('\n')}`);
  // Creator 官方命令行约定：36 表示成功，32/34 表示失败。
  // https://docs.cocos.com/creator/3.8/manual/en/editor/publish/publish-in-command-line.html
  if (status !== 0 && status !== 36) throw new Error(`Creator 返回异常退出码 ${status}`);
  for (const setting of ['"debug":false', '"sourceMaps":false', '"nativeCodeBundleMode":"wasm"', '"md5Cache":false']) {
    if (!log.includes(setting)) throw new Error(`构建日志缺少生效配置 ${setting}`);
  }
  syncPromoVideos(output);
  verifyOutput();
} catch (error) {
  console.error(`❌ ${error.message}\n完整构建日志：${logPath}`);
  process.exitCode = 1;
}
