#!/usr/bin/env node
import { existsSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { findTypeScript, root } from './cocos-paths.mjs';

function run(command, args, options = {}) {
  const result = spawnSync(command, args, { cwd: root, stdio: 'inherit', windowsHide: true, ...options });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${command} 退出码 ${result.status}`);
}

function executable(candidates, probe) {
  for (const command of candidates.filter(Boolean)) {
    const result = spawnSync(command, probe, { stdio: 'ignore', windowsHide: true });
    if (!result.error && result.status === 0) return command;
  }
  throw new Error(`找不到可执行命令：${candidates.filter(Boolean).join(' / ')}`);
}

try {
  const declarations = ['cc.custom-macro', 'cc', 'jsb', 'cc.env'];
  for (const name of declarations) {
    if (!existsSync(join(root, `reference-projects/catch-big-goose-cocos/temp/declarations/${name}.d.ts`))) {
      throw new Error('缺少 Cocos 类型声明；请先用 Creator 打开 reference-projects/catch-big-goose-cocos/，等待资源导入完成。');
    }
  }
  const tsc = findTypeScript();
  run(process.execPath, [tsc, '--noEmit', '-p', 'reference-projects/catch-big-goose-cocos/tsconfig.check.json']);
  const tests = readdirSync(join(root, 'tests')).filter(name => name.endsWith('.test.mjs'));
  run(process.execPath, ['--test', ...tests.map(name => join('tests', name))]);
  run(process.execPath, ['tools/verify-project.mjs']);
  run(process.execPath, ['tools/analyze-telemetry.mjs', 'tests/fixtures/telemetry.sample.json'],
    { stdio: ['ignore', 'ignore', 'inherit'] });

  // Git for Windows 的 Bash 不一定在 PATH 中；先查 PATH，再查 Git 安装目录。
  const git = spawnSync('where.exe', ['git'], { encoding: 'utf8', windowsHide: true });
  const gitPath = git.status === 0 ? git.stdout.trim().split(/\r?\n/)[0] : '';
  const bash = executable([
    process.env.BASH_PATH, 'bash',
    gitPath && join(dirname(gitPath), '../bin/bash.exe'),
    process.platform === 'win32' && join(process.env.ProgramFiles || 'C:/Program Files', 'Git/bin/bash.exe'),
  ], ['--version']);
  run(bash, ['-n', 'tools/check.sh', 'tools/build-web.sh', 'tools/art/compress_glb.sh']);

  const python = executable([process.env.PYTHON, 'python3', 'python'],
    ['-c', 'import sys; assert sys.version_info >= (3, 8)']);
  run(python, ['-B', '-c',
    'import ast,pathlib,sys; [ast.parse(p.read_text(encoding="utf-8-sig"), filename=str(p)) for arg in sys.argv[1:] for p in pathlib.Path(arg).glob("*.py")]',
    'tools']);
  console.log('✅ 类型、回归测试、项目约束、Shell 与 Python 语法全部通过');
} catch (error) {
  console.error(`❌ ${error.message}`);
  process.exitCode = 1;
}
