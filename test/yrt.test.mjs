import assert from 'node:assert/strict';
import { describe, test } from 'node:test';
import { execBin, packageVersion } from './test-utils.mjs';

describe('yrt サブコマンド', () => {
  test('引数なしのとき stderr にヘルプを表示する', async () => {
    const { stdout, stderr } = await execBin('yrt');
    assert.match(stderr, /yagisan yrt/);
    assert.match(stderr, /Commands:/);
    assert.equal(stdout, '');
  });

  test('--help を表示する', async () => {
    const { stdout, stderr } = await execBin('yrt', '--help');
    assert.match(stdout, /yagisan yrt/);
    assert.match(stdout, /Commands:/);
    assert.equal(stderr, '');
  });

  test('--version を表示する', async () => {
    const { stdout, stderr } = await execBin('yrt', '--version');
    assert.match(stdout, new RegExp(packageVersion));
    assert.equal(stderr, '');
  });

  describe('pack サブコマンド', () => {
    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack', '--help');
      assert.match(stdout, /yagisan yrt pack/);
      assert.match(stdout, /Positionals:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    test.skip('指定したファイルを pack する（手動確認）');
  });

  describe('pack-alpha サブコマンド', () => {
    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack-alpha', '--help');
      assert.match(stdout, /yagisan yrt pack-alpha/);
      assert.match(stdout, /Positionals:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack-alpha', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    test.skip('指定したファイルを旧型式で pack する（手動確認）');
  });
});
