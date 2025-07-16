package yagisan.reports.devtool.command;

import extype.Nullable;
import extype.ReadOnlyArray;
import extype.Tuple.Tuple2;
import extype.extern.Mixed.Mixed2;
import haxe.DynamicAccess;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.Fs;
import js.node.Path;
import jsasync.Nothing;
import yagisan.reports.shared.LegacyYrtFormat.packYrt as packLegacyYrt;
import yagisan.reports.shared.LegacyYrtFormat.unpackYrt as unpackLegacyYrt;
import yagisan.reports.shared.YrtFormat.YrtLayoutEntry;
import yagisan.reports.shared.YrtFormat.YrtPackage;
import yagisan.reports.shared.YrtFormat.pack as packYrt;
import yagisan.reports.shared.YrtFormat.unpack as unpackYrt;

@:expose
function yrtAlphaPackCheck(params:YrtAlphaPackParameter):Bool {
    if (!Fs.existsSync(params.xmlPath)) {
        throw 'Could not find xml: ${params.xmlPath}';
    }

    final idSet = new js.lib.Set();
    for (asset in params.assets) {
        final def = parseAssetString(asset);
        final path = def.path;
        final id = def.id;

        if (path == "" || id == "") {
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

@:expose
final yrtAlphaPack = jsasync(function (params:YrtAlphaPackParameter):Promise<Nothing> {
    final xml = loadXml(params.xmlPath).jsawait();
    final assets = loadAssets(params.assets).jsawait();
    final template = packLegacyYrt(xml, assets);

    final path = Path.parse(params.xmlPath);
    final outputPath = params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.yrt'));
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

function loadAssets(assets:ReadOnlyArray<String>):Promise<js.lib.Map<String, Uint8Array>> {
    return Promise.all(assets.map(asset -> {
        final def = parseAssetString(asset);
        final path = def.path;
        final id = def.id;
        FsPromises.readFile(path).then((buff:Buffer) -> new Tuple2(id, buff));
    })).then((loadedAssets:ReadOnlyArray<Tuple2<String, Buffer>>) -> {
        final assets = new js.lib.Map();
        for (x in loadedAssets) {
            assets.set(x.value1, (x.value2 : Uint8Array));
        }
        assets;
    });
}

function yrtPackCheck(params:YrtPackParameter):Bool {
    if (params.xmlPaths.length <= 0) {
        throw 'At least one XML file must be specified';
    }

    for (xmlPathWithName in params.xmlPaths) {
        final xmlPath = xmlPathWithName.split("@")[0].trim();
        if (!Fs.existsSync(xmlPath)) {
            throw 'Could not find xml: ${xmlPath}';
        }
    }

    if (params.style.nonEmpty() && !Fs.existsSync(params.style.get())) {
        throw 'Could not find style xml: ${params.style.get()}';
    }

    final idSet = new js.lib.Set();
    for (asset in params.assets) {
        final def = parseAssetString(asset);
        final path = def.path;
        final id = def.id;

        if (path == "" || id == "") {
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
    final layouts = loadXmls(params.xmlPaths).jsawait();
    final assets = if (params.assets.length > 0) {
        loadAssets(params.assets).jsawait();
    } else {
        null;
    }

    final style = if (params.style.nonEmpty()) {
        final styleXml = loadXml(params.style.get()).jsawait();
        Nullable.of(styleXml);
    } else {
        Nullable.empty();
    }

    final packed = packYrt({
        layouts: layouts,
        style: style,
        assets: Nullable.of(assets)
    });

    final outputPath = getOutputPath(params);
    FsPromises.writeFile(outputPath, Buffer.from(packed), {flag: "w"}).jsawait();
});

function getOutputPath(params:YrtPackParameter):String {
    final firstXmlPath = params.xmlPaths[0].split("@")[0].trim();
    final path = Path.parse(firstXmlPath);
    return params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.yrt'));
}

function loadXmls(xmlPaths:ReadOnlyArray<String>):Promise<Array<YrtLayoutEntry>> {
    return Promise.all(xmlPaths.map(xmlPathWithName -> {
        final tokens = xmlPathWithName.split("@");
        final xmlPath = tokens[0].trim();
        final customName = tokens[1]?.trim();

        final name = if (customName != null && customName != "") {
            Nullable.of(customName);
        } else {
            Nullable.empty();
        }

        FsPromises.readFile(xmlPath, {encoding: 'utf-8'}).then((xml:String) -> ({
            name: name,
            xml: xml
        } : YrtLayoutEntry));
    }));
}

typedef YrtPackParameter = {
    final xmlPaths:ReadOnlyArray<String>;
    final assets:ReadOnlyArray<String>;
    final style:Nullable<String>;
    final outputPath:Nullable<String>;
}

typedef YrtAlphaPackParameter = {
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
