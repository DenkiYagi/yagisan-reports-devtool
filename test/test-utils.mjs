import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import packageJson from "../package.json" with { type: "json" };

const execFileAsync = promisify(execFile);
const BIN_PATH = 'bin/main.js';

/**
 * `package.json` の `version` の値です。
 */
export const packageVersion = packageJson.version;

/**
 * テスト対象のCLIを実行するヘルパー関数です。
 *
 * @param {string[]} args - コマンドライン引数のリスト
 */
export async function execBin(...args) {
  try {
    return await execFileAsync('node', [BIN_PATH, ...args], { encoding: 'utf8' });
  } catch (error) {
    // Exit code 1 (help display) は正常な動作として扱う
    if (error.code === 1) {
      return {
        stdout: error.stdout || '',
        stderr: error.stderr || ''
      };
    }
    throw error;
  }
}

/**
 * ファイルパスの拡張子を変更します。
 * @param {string} filePath
 * @param {string} newExt
 * @returns {string} - 新しい拡張子を持つファイルパス
 */
export function changeExtension(filePath, newExt) {
  return filePath.replace(/\.[^.]+$/, newExt);
}

/**
 * 2つのファイルのバイナリ内容を比較します。
 * @param {string} path1 - 1つ目のファイルパス
 * @param {string} path2 - 2つ目のファイルパス
 * @returns {Promise<boolean>} - ファイルが同一の場合true
 */
export async function compareFiles(path1, path2) {
  const [file1, file2] = await Promise.all([
    readFile(path1),
    readFile(path2)
  ]);
  return Buffer.compare(file1, file2) === 0;
}

/**
 * ディレクトリ内のファイル一覧を再帰的に取得します。
 * @param {string} dir - ディレクトリパス
 * @returns {Promise<string[]>} - ファイルパスの配列
 */
export async function readDirRecursive(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = await Promise.all(entries.map(entry => {
    const path = join(dir, entry.name);
    return entry.isDirectory() ? readDirRecursive(path) : path;
  }));
  return files.flat();
}
