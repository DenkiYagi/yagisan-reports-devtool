package yagisan.reports.devtool;

import extype.extern.Mixed.Mixed2;
import js.lib.Promise;
import js.node.Buffer;
import js.node.Fs;

function isEmpty(x:Null<String>):Bool {
    return x == null || x.length <= 0;
}

@:jsRequire("node:fs/promises")
extern class FsPromises {
    static function writeFile(filename:FsPath, data:Buffer, ?options:Mixed2<String, FsWriteFileOptions>):Promise<Void>;
    static function readFile(path:String, ?options:{encoding:String, ?flag:FsOpenFlag}):Promise<Mixed2<Buffer, String>>;
}
