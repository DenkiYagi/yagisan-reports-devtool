import assert from 'node:assert/strict';
import { describe, test } from 'node:test';
import { execBin, packageVersion } from './test-utils.mjs';

describe('デフォルトコマンド', () => {
  test('引数なしのとき stderr にヘルプを表示する', async () => {
    const { stdout, stderr } = await execBin();
    assert.match(stderr, /yagisan \[options\] \[command\]/);
    assert.match(stderr, /Commands:/);
    assert.equal(stdout, '');
  });

  test('--help を表示する', async () => {
    const { stdout, stderr } = await execBin('--help');
    assert.match(stdout, /yagisan \[options\] \[command\]/);
    assert.match(stdout, /Commands:/);
    assert.equal(stderr, '');
  });

  test('--version を表示する', async () => {
    const { stdout, stderr } = await execBin('--version');
    assert.match(stdout, new RegExp(packageVersion));
    assert.equal(stderr, '');
  });
});
