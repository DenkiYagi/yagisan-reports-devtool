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
import yagisan.reports.shared.YrtFormat.YrtLayoutEntry;
import yagisan.reports.shared.YrtFormat.YrtPackage;
import yagisan.reports.shared.YrtFormat.pack as packYrt;
import yagisan.reports.shared.YrtFormat.unpack as unpackYrt;

using jsasync.JSAsyncTools;

@:expose
final yrtPack = jsasync(function (params:YrtPackParameter):Promise<Nothing> {
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

@:expose
final yrtUnpack = jsasync(function(params:YrtUnpackParameter):Promise<Nothing> {
    if (!Fs.existsSync(params.yrtPath)) {
        throw 'Could not find YRT file: ${params.yrtPath}';
    }

    final outputDir = determineOutputDir(params.yrtPath, params.destDir);
    ensureDirectoryExists(outputDir);

    final yrtData = FsPromises.readFile(params.yrtPath).jsawait();
    final yrtPackage:YrtPackage = switch unpackYrt((yrtData : Uint8Array)) {
        case Success(pkg): pkg;
        case IllegalFormat: throw 'Invalid YRT format: ${params.yrtPath}';
    }

    writeLayoutFiles(outputDir, yrtPackage.layouts).jsawait();

    if (yrtPackage.style.nonEmpty()) {
        writeStyleFile(outputDir, yrtPackage.style.get()).jsawait();
    }

    if (yrtPackage.assets.nonEmpty()) {
        final assets = yrtPackage.assets.get();
        if (assets.size > 0) {
            writeAssetFiles(outputDir, assets).jsawait();
        }
    }
});

private function getOutputPath(params:YrtPackParameter):String {
    final firstXmlPath = params.xmlPaths[0].split("@")[0].trim();
    final path = Path.parse(firstXmlPath);
    return params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.yrt'));
}

private function loadXmls(xmlPaths:ReadOnlyArray<String>):Promise<Array<YrtLayoutEntry>> {
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

private function writeLayoutFiles(outputDir:String, layouts:Array<YrtLayoutEntry>):Promise<Nothing> {
    final promises = [];
    for (i in 0...layouts.length) {
        final layout = layouts[i];
        // Determine filename
        final filename = if (layouts.length == 1 && layout.name.isEmpty()) {
            "layout.xml";
        } else if (layout.name.nonEmpty()) {
            '${sanitizeAssetId(layout.name.get())}.xml';
        } else {
            'layout_${i}.xml';
        }

        final layoutPath = Path.join(outputDir, filename);
        promises.push(FsPromises.writeFile(layoutPath, Buffer.from(layout.xml, 'utf-8')));
    }
    return Promise.all(promises).then(_ -> null);
}

private function writeStyleFile(outputDir:String, style:String):Promise<Nothing> {
    final stylePath = Path.join(outputDir, "style.xml");
    return FsPromises.writeFile(stylePath, Buffer.from(style, 'utf-8')).then(_ -> null);
}

typedef YrtPackParameter = {
    final xmlPaths:ReadOnlyArray<String>;
    final assets:ReadOnlyArray<String>;
    final style:Nullable<String>;
    final outputPath:Nullable<String>;
}

typedef YrtUnpackParameter = {
    final yrtPath:String;
    final destDir:Nullable<String>;
}
