package yagisan.reports.shared;

import extype.Nullable;
import haxe.DynamicAccess;
import js.Syntax;
import js.lib.Object;
import js.lib.Uint8Array;
import js.npm.MsgPack;

/**
    旧形式のYRTパッケージを作成・展開する静的メソッドを提供します。
**/
class LegacyYrtFormat {
    /**
        YRT形式のデータを作成します。

        - この関数では入力パラメーターの検証を行わない為、使用時は注意してください。
    **/
    public static function packYrt(layoutXml:String, ?assets:js.lib.Map<String, Uint8Array>):Uint8Array {
        final assetObject = new DynamicAccess();
        var hasAsset = false;
        if (assets != null && assets.size > 0) {
            for (k => v in assets) {
                if (v != null && Std.isOfType(v, Uint8Array)) {
                    assetObject.set(k, v);
                    hasAsset = true;
                }
            }
        }

        return if (hasAsset) {
            MsgPack.encode([layoutXml, assetObject]);
        } else {
            MsgPack.encode([layoutXml]);
        }
    }

    /**
        YRT形式のデータを展開します。
    **/
    public static function unpackYrt(yrt:Uint8Array):UnpackLegacyYrtResult {
        try {
            final raw:Dynamic = MsgPack.decode(yrt);
            if (raw == null || !Std.isOfType(raw, Array)) return IllegalFormat;

            final rawArray:Array<Dynamic> = raw;
            if (rawArray.length == 0 || rawArray.length > 2) return IllegalFormat;

            final xml:Any = rawArray[0];
            if (xml == null || !Std.isOfType(xml, String) || xml == "") return IllegalFormat;

            final rawAssets = rawArray[1];
            if (rawAssets != null) {
                if (!Std.isOfType(rawAssets, Object)) return IllegalFormat;

                final assets = new js.lib.Map();
                for (key in Object.keys(rawAssets)) {
                    final value = Syntax.field(rawAssets, key);
                    if (!Std.isOfType(value, Uint8Array)) return IllegalFormat;
                    assets.set(key, (value : Uint8Array));
                }

                return Success({ layoutXml: xml, assets: assets });
            } else {
                return Success({ layoutXml: xml, assets: new js.lib.Map() });
            }
        } catch (e) {
            return IllegalFormat;
        }
    }
}

enum UnpackLegacyYrtResult {
    Success(content:LegacyYrtContent);
    IllegalFormat;
}

typedef LegacyYrtContent = {
    final layoutXml:String;
    final assets:js.lib.Map<String, Uint8Array>;
}

private abstract RawYrtData(Array<Dynamic>) {
    public var xml(get, never):String;
    inline function get_xml() return this[0];

    public var assets(get, never):Nullable<Dynamic<Uint8Array>>;
    inline function get_assets() return this[1];

    public inline function new(xml:String, ?assets:Dynamic<Uint8Array>) {
        this = if (assets == null) {
            [xml];
        } else {
            [xml, assets];
        }
    }
}
