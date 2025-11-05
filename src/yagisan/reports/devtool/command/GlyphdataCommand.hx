package yagisan.reports.devtool.command;

import extype.Nullable;
import js.lib.Promise;
import js.node.Buffer;
import js.node.Fs;
import js.node.Path;
import jsasync.JSAsync.jsasync;
import jsasync.Nothing;
import yagisan.reports.shared.GlyphdataFormat;

using jsasync.JSAsyncTools;

@:expose
function glyphdataGenerateCheck(params:GlyphdataGenerateParameter):Bool {
	if (!Fs.existsSync(params.fontPath)) {
		throw 'Could not find font file: ${params.fontPath}';
	}

	return true;
}

@:expose
final glyphdataGenerate = jsasync(function(params:GlyphdataGenerateParameter):Promise<Nothing> {
	final fontBuffer = FsPromises.readFile(params.fontPath).jsawait();

	final result = GlyphdataFormat.generate(fontBuffer);

	final glyphdataBuffer = switch result {
			case Success(glyphdata):
				glyphdata;
			case InvalidFontBufferDataTypeError:
				throw 'Invalid font buffer data type. Expected Uint8Array.';
			case FontFaceDataProcessingError(errorMessage):
				throw 'Failed to process font face data: ${errorMessage}';
			case UnsupportedFontFileError(type):
				throw 'Unsupported font file type: ${type}';
			case EncodingError(errorMessage):
				throw 'Failed to encode glyph data: ${errorMessage}';
			case GlyphDataGeneratorFatalError(errorMessage):
				throw 'Fatal error during glyph data generation: ${errorMessage}';
		};

	final path = Path.parse(params.fontPath);
	final outputPath = params.outputPath.getOrElse(Path.join(path.dir, '${path.name}.glyphdata'));
	FsPromises.writeFile(outputPath, Buffer.from(glyphdataBuffer), {flag: "w"}).jsawait();
});

typedef GlyphdataGenerateParameter = {
	final fontPath:String;
	final outputPath:Nullable<String>;
}
