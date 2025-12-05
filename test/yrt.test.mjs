import assert from 'node:assert/strict';
import { describe, test, beforeEach, afterEach } from 'node:test';
import { rm, mkdir, readdir } from 'node:fs/promises';
import { execBin, packageVersion, compareFiles } from './test-utils.mjs';

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
    const testOutDir = 'test-out/yrt/pack-errors';
    const fixturesDir = 'test/fixtures/yrt';

    beforeEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
      await mkdir(testOutDir, { recursive: true });
    });

    afterEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
    });

    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack', '--help');
      assert.match(stdout, /yagisan yrt pack/);
      assert.match(stdout, /Arguments:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'pack', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    test('XML未指定の場合にエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /missing required argument/);
    });

    test('存在しないXMLを指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', 'nonexistent.xml', '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /Could not find xml/);
    });

    test('存在しないアセットを指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-A', 'nonexistent.png@asset1', '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /Could not find asset/);
    });

    test('存在しないスタイルを指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-S', 'nonexistent.xml', '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /Could not find style xml/);
    });

    test('-Sオプションを複数回指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-S', `${fixturesDir}/style.xml`, '-S', `${fixturesDir}/style.xml`, '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /Option -S can only be specified once/);
    });

    test('--styleオプションを複数回指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '--style', `${fixturesDir}/style.xml`, '--style', `${fixturesDir}/style.xml`, '-O', `${testOutDir}/output.yrt`);
      assert.match(stderr, /Option --style can only be specified once/);
    });

    test('-Oオプションを複数回指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-O', `${testOutDir}/output1.yrt`, '-O', `${testOutDir}/output2.yrt`);
      assert.match(stderr, /Option -O can only be specified once/);
    });

    test('--outオプションを複数回指定してエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '--out', `${testOutDir}/output1.yrt`, '--out', `${testOutDir}/output2.yrt`);
      assert.match(stderr, /Option --out can only be specified once/);
    });

    test('outで存在するファイルを指定したら上書き', async () => {
      const outputPath = `${testOutDir}/output.yrt`;

      // First pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-O', outputPath);
      const { readFile } = await import('node:fs/promises');
      const firstContent = await readFile(outputPath);

      // Second pack (overwrite)
      await execBin('yrt', 'pack', `${fixturesDir}/layout1.xml`, '-O', outputPath);
      const secondContent = await readFile(outputPath);

      // File should be overwritten (content should be different)
      assert.notDeepEqual(firstContent, secondContent, 'File should be overwritten with different content');
    });
  });

  describe('unpack サブコマンド', () => {
    const testOutDir = 'test-out/yrt/unpack-tests';
    const fixturesDir = 'test/fixtures/yrt';

    beforeEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
      await mkdir(testOutDir, { recursive: true });
    });

    afterEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
    });

    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'unpack', '--help');
      assert.match(stdout, /yagisan yrt unpack/);
      assert.match(stdout, /Arguments:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt', 'unpack', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    test('dest未指定の場合、YRTファイルと同じディレクトリに展開', async () => {
      const yrtPath = `${testOutDir}/test.yrt`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-O', yrtPath);

      // Unpack without dest
      await execBin('yrt', 'unpack', yrtPath);

      // Check files are in same directory
      const files = await readdir(testOutDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist in same directory as YRT file');
    });

    test('dest指定ありの場合、指定ディレクトリに展開', async () => {
      const yrtPath = `${testOutDir}/test.yrt`;
      const destDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-S', `${fixturesDir}/style.xml`, '-O', yrtPath);

      // Unpack with dest
      await execBin('yrt', 'unpack', yrtPath, '-D', destDir);

      // Check files are in dest directory
      const files = await readdir(destDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist in dest directory');
      assert.ok(files.includes('style.xml'), 'style.xml should exist in dest directory');
    });

    test('指定したYRTが存在しなかったらエラーを出力', async () => {
      const { stderr } = await execBin('yrt', 'unpack', 'nonexistent.yrt');
      assert.match(stderr, /Could not find YRT file/);
    });
  });

  describe('pack/unpack ラウンドトリップ', () => {
    const testOutDir = 'test-out/yrt';
    const fixturesDir = 'test/fixtures/yrt';

    beforeEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
      await mkdir(testOutDir, { recursive: true });
    });

    afterEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
    });

    test('単一レイアウト、スタイルなし、アセットなし', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/layout.xml`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('単一レイアウト、スタイルあり、アセットなし', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-S', `${fixturesDir}/style.xml`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist');
      assert.ok(files.includes('style.xml'), 'style.xml should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/layout.xml`, '-S', `${unpackDir}/style.xml`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('単一レイアウト、スタイルなし、アセット1つ', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-A', `${fixturesDir}/asset1.png@asset1`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist');
      assert.ok(files.includes('assets'), 'assets directory should exist');

      const assetFiles = await readdir(`${unpackDir}/assets`);
      assert.ok(assetFiles.includes('asset_asset1'), 'asset_asset1 should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/layout.xml`, '-A', `${unpackDir}/assets/asset_asset1@asset1`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('単一レイアウト、スタイルなし、アセット複数', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout.xml`, '-A', `${fixturesDir}/asset1.png@asset1`, '-A', `${fixturesDir}/asset2.png@asset2`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const assetFiles = await readdir(`${unpackDir}/assets`);
      assert.ok(assetFiles.includes('asset_asset1'), 'asset_asset1 should exist');
      assert.ok(assetFiles.includes('asset_asset2'), 'asset_asset2 should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/layout.xml`, '-A', `${unpackDir}/assets/asset_asset1@asset1`, '-A', `${unpackDir}/assets/asset_asset2@asset2`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('複数レイアウトでレイアウト名なし', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout1.xml`, `${fixturesDir}/layout2.xml`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout_0.xml'), 'layout_0.xml should exist');
      assert.ok(files.includes('layout_1.xml'), 'layout_1.xml should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/layout_0.xml`, `${unpackDir}/layout_1.xml`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('複数レイアウトでレイアウト名あり', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack', `${fixturesDir}/layout1.xml@first`, `${fixturesDir}/layout2.xml@second`, '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('first.xml'), 'first.xml should exist');
      assert.ok(files.includes('second.xml'), 'second.xml should exist');

      // Repack
      await execBin('yrt', 'pack', `${unpackDir}/first.xml@first`, `${unpackDir}/second.xml@second`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('複数レイアウト、スタイルあり、アセット複数', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt', 'pack',
        `${fixturesDir}/layout1.xml`,
        `${fixturesDir}/layout2.xml`,
        '-S', `${fixturesDir}/style.xml`,
        '-A', `${fixturesDir}/asset1.png@asset1`,
        '-A', `${fixturesDir}/asset2.png@asset2`,
        '-O', yrt1);

      // Unpack
      await execBin('yrt', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout_0.xml'), 'layout_0.xml should exist');
      assert.ok(files.includes('layout_1.xml'), 'layout_1.xml should exist');
      assert.ok(files.includes('style.xml'), 'style.xml should exist');
      assert.ok(files.includes('assets'), 'assets directory should exist');

      // Repack
      await execBin('yrt', 'pack',
        `${unpackDir}/layout_0.xml`,
        `${unpackDir}/layout_1.xml`,
        '-S', `${unpackDir}/style.xml`,
        '-A', `${unpackDir}/assets/asset_asset1@asset1`,
        '-A', `${unpackDir}/assets/asset_asset2@asset2`,
        '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });
  });

  describe('yrt-alpha サブコマンド', () => {
    test('引数なしのとき stderr にヘルプを表示する', async () => {
      const { stdout, stderr } = await execBin('yrt-alpha');
      assert.match(stderr, /yagisan yrt-alpha/);
    });

    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt-alpha', '--help');
      assert.match(stdout, /yagisan yrt-alpha/);
      assert.match(stdout, /Commands:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('yrt-alpha', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    describe('pack サブコマンド', () => {
      test('--help を表示する', async () => {
        const { stdout, stderr } = await execBin('yrt-alpha', 'pack', '--help');
        assert.match(stdout, /yagisan yrt-alpha pack/);
        assert.match(stdout, /Arguments:/);
        assert.equal(stderr, '');
      });

      test('--version を表示する', async () => {
        const { stdout, stderr } = await execBin('yrt-alpha', 'pack', '--version');
        assert.match(stdout, new RegExp(packageVersion));
        assert.equal(stderr, '');
      });
    });

    describe('unpack サブコマンド', () => {
      test('--help を表示する', async () => {
        const { stdout, stderr } = await execBin('yrt-alpha', 'unpack', '--help');
        assert.match(stdout, /yagisan yrt-alpha unpack/);
        assert.match(stdout, /Arguments:/);
        assert.equal(stderr, '');
      });

      test('--version を表示する', async () => {
        const { stdout, stderr } = await execBin('yrt-alpha', 'unpack', '--version');
        assert.match(stdout, new RegExp(packageVersion));
        assert.equal(stderr, '');
      });
    });
  });

  describe('yrt-alpha pack/unpack ラウンドトリップ', () => {
    const testOutDir = 'test-out/yrt/alpha';
    const fixturesDir = 'test/fixtures/yrt';

    beforeEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
      await mkdir(testOutDir, { recursive: true });
    });

    afterEach(async () => {
      await rm(testOutDir, { recursive: true, force: true });
    });

    test('アセットなし', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt-alpha', 'pack', `${fixturesDir}/layout.xml`, '-O', yrt1);

      // Unpack
      await execBin('yrt-alpha', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist');

      // Repack
      await execBin('yrt-alpha', 'pack', `${unpackDir}/layout.xml`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('アセット1つ', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt-alpha', 'pack', `${fixturesDir}/layout.xml`, '-A', `${fixturesDir}/asset1.png@asset1`, '-O', yrt1);

      // Unpack
      await execBin('yrt-alpha', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const files = await readdir(unpackDir);
      assert.ok(files.includes('layout.xml'), 'layout.xml should exist');
      assert.ok(files.includes('assets'), 'assets directory should exist');

      const assetFiles = await readdir(`${unpackDir}/assets`);
      assert.ok(assetFiles.includes('asset_asset1'), 'asset_asset1 should exist');

      // Repack
      await execBin('yrt-alpha', 'pack', `${unpackDir}/layout.xml`, '-A', `${unpackDir}/assets/asset_asset1@asset1`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });

    test('アセット複数', async () => {
      const yrt1 = `${testOutDir}/test1.yrt`;
      const yrt2 = `${testOutDir}/test2.yrt`;
      const unpackDir = `${testOutDir}/unpacked`;

      // Pack
      await execBin('yrt-alpha', 'pack', `${fixturesDir}/layout.xml`, '-A', `${fixturesDir}/asset1.png@asset1`, '-A', `${fixturesDir}/asset2.png@asset2`, '-O', yrt1);

      // Unpack
      await execBin('yrt-alpha', 'unpack', yrt1, '-D', unpackDir);

      // Verify unpacked files
      const assetFiles = await readdir(`${unpackDir}/assets`);
      assert.ok(assetFiles.includes('asset_asset1'), 'asset_asset1 should exist');
      assert.ok(assetFiles.includes('asset_asset2'), 'asset_asset2 should exist');

      // Repack
      await execBin('yrt-alpha', 'pack', `${unpackDir}/layout.xml`, '-A', `${unpackDir}/assets/asset_asset1@asset1`, '-A', `${unpackDir}/assets/asset_asset2@asset2`, '-O', yrt2);

      // Compare
      const isSame = await compareFiles(yrt1, yrt2);
      assert.ok(isSame, 'Round-trip should produce identical YRT files');
    });
  });
});
