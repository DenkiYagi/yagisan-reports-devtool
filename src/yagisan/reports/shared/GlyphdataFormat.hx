package yagisan.reports.shared;

import js.lib.Uint8Array;
import js.npm.MsgPack;
import yagisan.reports.core.font.glyphdata.GlyphDataGenerator.generateRawGlyphData;
import yagisan.reports.core.font.glyphdata.MsgPackExtensionCodec;

/**
	現行形式のglyphdataを作成・展開する静的メソッドを提供します。
**/
class GlyphdataFormat {
	static final codec = MsgPackExtensionCodec.createForSetMap();

	/**
		フォントファイルを元にglyphdataを生成します。

		@param fontBuffer フォントファイル (TTF/OTF) のデータです。
	**/
	public static function generate(fontBuffer:Uint8Array):GenerateGlyphdataResult {
		if (!Std.isOfType(fontBuffer, Uint8Array))
			return InvalidFontBufferDataTypeError;

		final rawGlyphData = switch generateRawGlyphData(fontBuffer, {}) {
			case Success(glyphData, rawFont):
				glyphData;
			case UnsupportedFontFileError(type):
				return UnsupportedFontFileError(type);
			case FatalError(error):
				return GlyphDataGeneratorFatalError(error.message);
		};
		return Success(MsgPack.encode(rawGlyphData, {extensionCodec: codec}));
	}
}

enum GenerateGlyphdataResult {
	/**
		glyphdataの生成に成功した場合に返されます。

		`glyphdata` はMsgPackでエンコードされたデータです。
	**/
	Success(glyphdata:Uint8Array);

	/**
		フォントバッファがUint8Arrayでない場合に返されます。
	**/
	InvalidFontBufferDataTypeError;

	/**
		フォントファイルの形式がサポートされていない場合に返されます。

		`type` はフォントファイルの形式です（例: `"TTF"`, `"WOFF"`）。
	**/
	UnsupportedFontFileError(type:String);

	/**
		glyphdataの生成中に致命的なエラーが発生した場合に返されます。

		`error` はエラーメッセージです。
	**/
	GlyphDataGeneratorFatalError(error:String);
}
