#!/usr/bin/env node

import { readFileSync } from 'node:fs';

const path = process.argv[2];
if (!path) {
  console.error('用法：node tools/analyze-telemetry.mjs <events.json>');
  process.exit(1);
}

const raw = JSON.parse(readFileSync(path, 'utf8'));
const events = Array.isArray(raw) ? raw : raw.events;
if (!Array.isArray(events)) throw new Error('输入必须是事件数组或 { events: [...] }');

const byName = name => events.filter(event => event.name === name);
const sessions = new Set(events.map(event => event.sessionId).filter(Boolean));
const starts = byName('round_start');
const ends = byName('round_end');
const finalByRound = new Map();
for (const event of ends) finalByRound.set(event.props?.roundId ?? `${event.sessionId}:${event.at}`, event);

console.log(`# 抓住大鹅种子数据简报`);
console.log(`\n- 会话数：${sessions.size}`);
console.log(`- 首页到达会话：${new Set(byName('home_view').map(e => e.sessionId)).size}`);
console.log(`- 开局数：${starts.length}`);
console.log(`- 主动退出：${byName('round_exit').length}`);
console.log(`- 运行时错误：${byName('runtime_error').length}`);
console.log(`- CDN 降级：${byName('remote_asset_fallback').length}`);

console.log('\n| 难度 | 开局 | 完成结算 | 胜利 | 胜率 | 平均完成度 |');
console.log('|---|---:|---:|---:|---:|---:|');
for (const level of [1, 2, 3]) {
  const levelStarts = starts.filter(e => e.props?.level === level);
  const levelEnds = [...finalByRound.values()].filter(e => e.props?.level === level);
  const wins = levelEnds.filter(e => e.props?.win === true).length;
  const avg = levelEnds.length
    ? levelEnds.reduce((sum, e) => sum + Number(e.props?.progress ?? 0), 0) / levelEnds.length : 0;
  const winRate = levelEnds.length ? wins / levelEnds.length * 100 : 0;
  console.log(`| ${level} | ${levelStarts.length} | ${levelEnds.length} | ${wins} | ${winRate.toFixed(1)}% | ${avg.toFixed(1)}% |`);
}
