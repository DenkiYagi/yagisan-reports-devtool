package yagisan.reports.devtool.command;

import extype.Nullable;
import extype.ReadOnlyArray;
import extype.Tuple.Tuple2;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.Fs;
import js.node.Path;
import jsasync.Nothing;

typedef AssetDefinition = {
    final path:String;
    final id:String;
}

/**
 * Parse an asset string in the format "path@id"
 */
function parseAssetString(value:String):AssetDefinition {
    final tokens = value.split("@");
    return {
        path: tokens[0].trim(),
        id: tokens[1]?.trim() ?? "",
    }
}

/**
 * Load an XML file
 */
function loadXml(xmlPath:String):Promise<String> {
    return FsPromises.readFile(xmlPath, {encoding: 'utf-8'});
}

/**
 * Load multiple asset files and return as a Map
 */
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

/**
 * Determine the output directory for unpacking.
 * If destDir is provided, use it; otherwise, use the directory of the YRT file.
 */
function determineOutputDir(yrtPath:String, destDir:Nullable<String>):String {
    return if (destDir.nonEmpty()) {
        destDir.get();
    } else {
        Path.parse(yrtPath).dir;
    }
}

/**
 * Sanitize an asset ID to make it filesystem-safe by replacing unsafe characters with underscores
 */
function sanitizeAssetId(id:String):String {
    var sanitized = id;
    sanitized = StringTools.replace(sanitized, "/", "_");
    sanitized = StringTools.replace(sanitized, "\\", "_");
    sanitized = StringTools.replace(sanitized, ":", "_");
    sanitized = StringTools.replace(sanitized, "*", "_");
    sanitized = StringTools.replace(sanitized, "?", "_");
    sanitized = StringTools.replace(sanitized, "\"", "_");
    sanitized = StringTools.replace(sanitized, "<", "_");
    sanitized = StringTools.replace(sanitized, ">", "_");
    sanitized = StringTools.replace(sanitized, "|", "_");
    return sanitized;
}

/**
 * Write asset files to the assets directory
 */
function writeAssetFiles(outputDir:String, assets:js.lib.Map<String, Uint8Array>):Promise<Nothing> {
    final assetsDir = Path.join(outputDir, "assets");
    ensureDirectoryExists(assetsDir);

    final promises = [];
    for (id => data in assets) {
        final sanitizedId = sanitizeAssetId(id);
        final assetPath = Path.join(assetsDir, 'asset_${sanitizedId}');
        promises.push(FsPromises.writeFile(assetPath, Buffer.from(data)));
    }

    return Promise.all(promises).then(_ -> null);
}

/**
 * Ensure a directory exists, creating it recursively if necessary
 */
function ensureDirectoryExists(dir:String):Void {
    if (!Fs.existsSync(dir)) {
        js.Syntax.code("require('fs').mkdirSync({0}, {recursive: true})", dir);
    }
}
