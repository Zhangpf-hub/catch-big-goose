import assert from 'node:assert/strict';
import test from 'node:test';
import { existsSync, readFileSync } from 'node:fs';
import { loadCore, plain } from './helpers/load-core.mjs';

test('数码工坊拥有独立九件物品和可进入地图节点，三关保持完整三消组', () => {
  const { THEMES, CHALLENGE_MAPS, buildLevels, getActiveTheme } = loadCore('LevelConfig', {
    modules: { './SaveData': { SaveData: { getTheme: () => 'electronics' } } },
  });
  const theme = THEMES.find(t => t.id === 'electronics');
  assert(theme && theme.skinId === 'electronics');
  assert.equal(new Set(theme.family).size, 9);
  assert.equal(getActiveTheme().id, theme.id);
  assert(CHALLENGE_MAPS.some(m => m.id === theme.id && m.themeId === theme.id));
  const levels = buildLevels(theme.family);
  assert.deepEqual(plain(levels.map(l => l.items.length)), [4, 6, 9]);
  assert.deepEqual(plain(levels.map(l => l.items.length * l.groupsPerItem * 3)), [48, 54, 81]);
  for (const id of theme.family) {
    assert(existsSync(`reference-projects/catch-big-goose-cocos/assets/resources/models/${id}.glb`));
    assert(existsSync(`reference-projects/catch-big-goose-cocos/assets/resources/icons/${id}.png`));
  }
  for (const file of ['models/tray_electronics.glb', 'textures/bg_electronics.jpg',
    'textures/challenge-ui/station-medallion-electronics.png']) {
    assert(existsSync(`reference-projects/catch-big-goose-cocos/assets/resources/${file}`));
  }
  const home = readFileSync('reference-projects/catch-big-goose-cocos/assets/scripts/core/ui/HomeScreen.ts', 'utf8');
  assert(home.includes('station-medallion-electronics/texture'));
});
