package yagisan.reports.devtool.command;

import extype.Nullable;
import jsasync.Nothing;
import js.lib.Uint8Array;
import yagisan.reports.shared.TemplatePacker.packTemplate;
import extype.Tuple.Tuple2;
import extype.ReadOnlyArray;
import extype.extern.Mixed.Mixed2;
import haxe.DynamicAccess;
import js.lib.Promise;
import js.node.Buffer;
import js.node.Fs;
import js.node.Path;

function yrtPackCheck(params:YrtPackParameter):Bool {
    if (!Fs.existsSync(params.xmlPath)) {
        throw 'Could not find xml: ${params.xmlPath}';
    }

    final idSet = new js.lib.Set();
    for (asset in params.assets) {
        final def = parseAssetString(asset);
        final path = def.path;
        final id = def.id;

        if (isEmpty(path) || isEmpty(id)) {
            throw 'Invalid argument: asset ${asset}';
        }
        if (!Fs.existsSync(path)) {
            throw 'Could not find asset: ${path}';
        }
        if (idSet.has(id)) {
            throw 'Same asset id specified: ${id}';
        }

        idSet.add(id);
    }

    return true;
}

final yrtPack = jsasync(function (params:YrtPackParameter):Promise<Nothing> {
    final xml = loadXml(params.xmlPath).jsawait();
    final assetObj = loadAssets(params.assets).jsawait();
    final template = packTemplate(xml, assetObj);

    final outputPath = getOutputPath(params);
    FsPromises.writeFile(outputPath, Buffer.from(template), {flag: "w"}).jsawait();
});

function parseAssetString(value:String):AssetDefinition {
    final tokens = value.split("@");
    return {
        path: tokens[0].trim(),
        id: tokens[1]?.trim() ?? "",
    }
}

function loadXml(xmlPath:String):Promise<String> {
    return FsPromises.readFile(xmlPath, {encoding: 'utf-8'});
}

function loadAssets(assets:ReadOnlyArray<String>):Promise<Dynamic<Uint8Array>> {
    return Promise.all(assets.map(asset -> {
        final def = parseAssetString(asset);
        final path = def.path;
        final id = def.id;
        FsPromises.readFile(path).then((buff:Buffer) -> new Tuple2(id, buff));
    })).then((loadedAssets:ReadOnlyArray<Tuple2<String, Buffer>>) -> {
        final assetsObj = new DynamicAccess();
        for (x in loadedAssets) {
            assetsObj.set(x.value1, (x.value2 : Uint8Array));
        }
        assetsObj;
    });
}

function getOutputPath(params:YrtPackParameter):String {
    final path = Path.parse(params.xmlPath);
    return params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.yrt'));
}

typedef YrtPackParameter = {
    final xmlPath:String;
    final assets:ReadOnlyArray<String>;
    final outputPath:Nullable<String>;
}

typedef AssetDefinition = {
    final path:String;
    final id:String;
}

@:jsRequire("node:fs/promises")
extern class FsPromises {
    static function writeFile(filename:FsPath, data:Buffer, ?options:Mixed2<String, FsWriteFileOptions>):Promise<Void>;
    static function readFile(path:String, ?options:{encoding:String, ?flag:FsOpenFlag}):Promise<Mixed2<Buffer, String>>;
}
