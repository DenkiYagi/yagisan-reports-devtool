package yagisan.reports.shared;

import js.lib.Uint8Array;
import yagisan.reports.core.font.GlyphDataApi.generateGlyphDataBytes;

/**
	現行形式のglyphdataを作成・展開する静的メソッドを提供します。
**/
class GlyphdataFormat {
	/**
		フォントファイルを元にglyphdataを生成します。

		@param fontBuffer フォントファイル (TTF/OTF) のデータです。
	**/
	public static function generate(fontBuffer:Uint8Array):GenerateGlyphdataResult {
		if (!Std.isOfType(fontBuffer, Uint8Array))
			return InvalidFontBufferDataTypeError;

		return switch generateGlyphDataBytes(fontBuffer) {
			case Success(glyphData, rawFont):
				Success(glyphData);
			case UnsupportedFontFileError(type):
				UnsupportedFontFileError(type);
			case FatalError(error):
				GlyphDataGeneratorFatalError(error.message);
		};
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
