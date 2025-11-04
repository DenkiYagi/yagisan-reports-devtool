import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
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
export function execBin(...args) {
  return execFileAsync('node', [BIN_PATH, ...args], { encoding: 'utf8' });
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
