import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCore } from './helpers/load-core.mjs';

test('挑战关加深堆叠，三消数量保持完整且不生成不可配对的石头', () => {
  const { buildLevels, validateLevel } = loadCore('LevelConfig', {
    modules: { './SaveData': { SaveData: { getTheme: () => null } } },
  });
  const family = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];
  const levels = buildLevels(family);
  assert.deepEqual(Array.from(levels, level => level.items.length * level.groupsPerItem * 3),
    [48, 54, 81]);
  assert.deepEqual(Array.from(levels, level => level.pileLayers ?? 3.1), [3.1, 3.4, 3.9]);
  for (const level of levels) {
    assert.equal(level.distractors ?? 0, 0);
    assert.equal(validateLevel(level), true);
  }
});
