import assert from 'node:assert/strict';
import { describe, test } from 'node:test';
import { changeExtension, execBin, packageVersion } from './test-utils.mjs';
import { readdir, rm, stat, unlink, mkdir } from 'node:fs/promises';
import { basename, join } from 'node:path';

describe('glyphdata サブコマンド', () => {
  test('引数なしのとき stderr にヘルプを表示する', async () => {
    const { stdout, stderr } = await execBin('glyphdata');
    assert.match(stderr, /yagisan glyphdata/);
    assert.match(stderr, /Commands:/);
    assert.equal(stdout, '');
  });

  test('--help を表示する', async () => {
    const { stdout, stderr } = await execBin('glyphdata', '--help');
    assert.match(stdout, /yagisan glyphdata/);
    assert.match(stdout, /Commands:/);
    assert.equal(stderr, '');
  });

  test('--version を表示する', async () => {
    const { stdout, stderr } = await execBin('glyphdata', '--version');
    assert.match(stdout, new RegExp(packageVersion));
    assert.equal(stderr, '');
  });

  describe('generate サブコマンド', async () => {
    test('--help を表示する', async () => {
      const { stdout, stderr } = await execBin('glyphdata', 'generate', '--help');
      assert.match(stdout, /yagisan glyphdata generate/);
      assert.match(stdout, /Positionals:/);
      assert.equal(stderr, '');
    });

    test('--version を表示する', async () => {
      const { stdout, stderr } = await execBin('glyphdata', 'generate', '--version');
      assert.match(stdout, new RegExp(packageVersion));
      assert.equal(stderr, '');
    });

    describe("フォントを入力して glyphdata を生成できる", async () => {
      const fontsDir = "test/fonts";
      const fontPaths = (await readdir(fontsDir))
        .map(file => join(fontsDir, file))
        .filter(file => file.endsWith('.ttf') || file.endsWith('.otf'));
      if (fontPaths.length === 0) {
        const msg = [
          "リポジトリー軽量化のため、テスト用フォントファイルはgit追跡対象にしていません。",
          "test/fonts/ ディレクトリーに任意のフォントファイルを配置してからテストを実行してください。"
        ].join("\n");
        throw new Error(msg);
      }

      test('指定したフォントから glyphdata を生成して同一ディレクトリーに保存する', async () => {
        for (const fontPath of fontPaths) {
          const { stdout, stderr } = await execBin('glyphdata', 'generate', fontPath);
          assert.equal(stdout, '');
          assert.equal(stderr, '');

          const outPath = changeExtension(fontPath, '.glyphdata');
          try {
            const fileStat = await stat(outPath);
            assert.ok(fileStat.size > 0, '生成された glyphdata ファイルのサイズが 0 です');
          } finally {
            await unlink(outPath); // clean up
          }
        }
      });

      test('指定したフォントから glyphdata を生成して --out のパスに保存する', async () => {
        // 出力先準備
        const outDir = 'test-out/glyphdata';
        await rm(outDir, { recursive: true, force: true });
        await mkdir(outDir, { recursive: true });

        for (const fontPath of fontPaths) {
          const outFile = changeExtension(basename(fontPath), '.glyphdata');
          const outPath = join(outDir, outFile);
          const { stdout, stderr } = await execBin('glyphdata', 'generate', fontPath, '--out', outPath);
          assert.equal(stdout, '');
          assert.equal(stderr, '');

          const fileStat = await stat(outPath);
          assert.ok(fileStat.size > 0, '生成された glyphdata ファイルのサイズが 0 です');
        }
      });
    });
  });
});
