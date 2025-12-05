package yagisan.reports.devtool.command;

import extype.Nullable;
import extype.ReadOnlyArray;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.Fs;
import js.node.Path;
import jsasync.JSAsync.jsasync;
import jsasync.Nothing;
import yagisan.reports.devtool.command.YrtUtils;
import yagisan.reports.shared.LegacyYrtFormat.packYrt as packLegacyYrt;
import yagisan.reports.shared.LegacyYrtFormat.unpackYrt as unpackLegacyYrt;

using jsasync.JSAsyncTools;

@:expose
final yrtAlphaPack = jsasync(function (params:YrtAlphaPackParameter):Promise<Nothing> {
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

    final xml = loadXml(params.xmlPath).jsawait();
    final assets = loadAssets(params.assets).jsawait();
    final template = packLegacyYrt(xml, assets);

    final path = Path.parse(params.xmlPath);
    final outputPath = params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.yrt'));
    FsPromises.writeFile(outputPath, Buffer.from(template), {flag: "w"}).jsawait();
});

@:expose
final yrtAlphaUnpack = jsasync(function(params:YrtAlphaUnpackParameter):Promise<Nothing> {
    if (!Fs.existsSync(params.yrtPath)) {
        throw 'Could not find YRT file: ${params.yrtPath}';
    }

    final outputDir = determineOutputDir(params.yrtPath, params.destDir);
    ensureDirectoryExists(outputDir);

    final yrtData = FsPromises.readFile(params.yrtPath).jsawait();
    final content = switch unpackLegacyYrt((yrtData : Uint8Array)) {
        case Success(c): c;
        case IllegalFormat: throw 'Invalid YRT format (legacy): ${params.yrtPath}';
    }

    final layoutPath = Path.join(outputDir, "layout.xml");
    FsPromises.writeFile(layoutPath, Buffer.from(content.layoutXml, 'utf-8')).jsawait();

    if (content.assets.size > 0) {
        writeAssetFiles(outputDir, content.assets).jsawait();
    }
});

typedef YrtAlphaPackParameter = {
    final xmlPath:String;
    final assets:ReadOnlyArray<String>;
    final outputPath:Nullable<String>;
}

typedef YrtAlphaUnpackParameter = {
    final yrtPath:String;
    final destDir:Nullable<String>;
}
