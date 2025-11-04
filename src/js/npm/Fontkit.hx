package js.npm;

import haxe.extern.EitherType;
import js.lib.ArrayBufferView;

#if jsImport
@:js.import(@star "@denkiyagi/fontkit")
#else
@:jsRequire("@denkiyagi/fontkit")
#end
extern class Fontkit {
    static function create(buffer:ArrayBufferView, ?postscriptName:String):FontOrFontCollection;
}

typedef FontOrFontCollection = {
    /**
        この値が `"TTF"`, `"WOFF"`, `"WOFF2"` のいずれかなら、`TTFFont` 型にキャスト可能です。
    **/
    var type:String;
}

typedef TTFFont = {
    var type:String;

    var postscriptName:Null<String>;
    var fullName:Null<String>;
    var familyName:Null<String>;
    var subfamilyName:Null<String>;
    var copyright:Null<String>;
    var version:Null<String>;

    var unitsPerEm:Float;
    var ascent:Float;
    var descent:Float;
    var lineGap:Float;
    var underlinePosition:Float;
    var underlineThickness:Float;
    var italicAngle:Float;
    var capHeight:Float;
    var xHeight:Float;
    var bbox:BoundingBox;

    var vhea:Null<{
        var ascent:Float;
        var descent:Float;
        var lineGap:Float;
    }>;

    var numGlyphs:Int;
    var characterSet:Array<Int>;
    var nonDefaultUVSSet:Array<{baseCharacter:Int, variationSelector:Int, glyphID:Int}>;
    var availableFeatures:TypeFeatures;

    function glyphForCodePoint(codePoint:Int):Glyph;
    function hasGlyphForCodePoint(codePoint:Int):Bool;
    function glyphsForString(str:String):Array<Glyph>;
    function stringsForGlyph(gid:Int):Array<String>;

    function widthOfGlyph(glyphId:Int):Float;
    function layout(str:EitherType<String, Array<Glyph>>, ?features:TypeFeatures, ?advancedParams:LayoutAdvancedParams):GlyphRun;

    function getGlyph(glyphId:Int, ?codePoints:Array<Int>):Glyph;
}

typedef BoundingBox = {} // 使わないので省略
typedef Path = {} // 使わないので省略

typedef Glyph = {
    var id:Int;
    var codePoints:Array<Int>;
    var path:Path;
    var bbox:BoundingBox;
    var cbox:BoundingBox;
    var advanceWidth:Float;
    var advanceHeight:Float;
}

typedef GlyphPosition = {} // 使わないので省略

typedef GlyphRun = {
    var glyphs:Array<Glyph>;
    var positions:Null<Array<GlyphPosition>>;
    var script:String;
    var language:Null<String>;
    var direction:Null<String>;
    var features:Any;
    var advanceWidth:Float;
    var advanceHeight:Float;
    var bbox:BoundingBox;
}

typedef TypeFeatures = {} // 使わないので省略

typedef LayoutAdvancedParams = {
    var ?script:String;
    var ?language:String;
    var ?direction:String;
    var ?shaper:Shaper;
    var ?skipPerGlyphPositioning:Bool;
};

interface Shaper {
    // 省略
}

#if jsImport
@:js.import("@denkiyagi/fontkit", "DefaultShaper")
#else
@:jsRequire("@denkiyagi/fontkit", "DefaultShaper")
#end
extern class DefaultShaper implements Shaper {
    public function new();
}
