package yagisan.reports.shared;

import extype.Nullable;
import haxe.DynamicAccess;
import js.Syntax;
import js.lib.Object;
import js.lib.Uint8Array;
import js.npm.MsgPack;

/**
    現行形式のYRTパッケージを作成・展開する静的メソッドを提供します。
**/
class YrtFormat {
    /**
        YRT形式のデータを作成します。
    **/
    public static function pack(yrt:YrtPackage):Uint8Array {
        if (yrt.layouts.length <= 0) {
            throw "YRTパッケージはレイアウトXMLを1つ以上含む必要があります。";
        }

        return MsgPack.encode([
            // header : doctype
            "YRT",
            // header : vresion
            1,
            // body
            {
                // Layouts : [name, xml]
                l: yrt.layouts.map(x -> [x.name.get(), x.xml]),
                // Style
                s: yrt.style.get(),
                // Assets
                a: yrt.assets.fold(
                    () -> null,
                    x -> {
                        if (x.size > 0) {
                            final obj = new DynamicAccess<Uint8Array>();
                            for (k => v in x) obj.set(k, v);
                            obj;
                        } else {
                            null;
                        }
                    })
            }
        ]);
    }

    /**
        YRT形式のデータを展開します。
    **/
    public static function unpack(binary:Uint8Array):UnpackYrtResult {
        try {
            final raw = MsgPack.decode(binary);
            if (raw == null || !isArray(raw) || (raw : Array<Any>).length != 3) return IllegalFormat;

            // doctypeチェック
            // `doctype=YRT`のみをサポート
            final doctype = (raw : Array<Dynamic>)[0];
            if (Syntax.strictNeq(doctype, "YRT")) return IllegalFormat;

            // versionチェック
            // `version=1`のみをサポート。2以降は将来的な拡張用として予約。
            final version = (raw : Array<Dynamic>)[1];
            if (version == null || !isInt(version)) return IllegalFormat;
            if (version != 1) return IllegalFormat;

            // bodyチェック
            final body = (raw : Array<Dynamic>)[2];
            if (body == null || !isObject(body)) return IllegalFormat;

            // layoutsは必ず1つ以上存在しなければならない
            if (body.l == null || !isArray(body.l) || (body.l : Array<Any>).length <= 0) return IllegalFormat;

            final layouts = [for (entry in (body.l : Array<Any>)) {
                if (entry == null || !isArray(entry) || (entry : Array<Any>).length != 2) return IllegalFormat;

                final name = (entry : Array<Any>)[0];
                final xml = (entry : Array<Any>)[1];

                if (name != null && !isString(name)) return IllegalFormat;
                if (xml == null || !isString(xml)) return IllegalFormat;

                ({
                    name: name,
                    xml: xml
                } : YrtLayoutEntry);
            }];

            // nameの重複チェック
            final nameSet = new js.lib.Set<String>();
            for (layout in layouts) {
                if (layout.name.nonEmpty()) {
                    final name = layout.name.get();
                    if (nameSet.has(name)) return IllegalFormat;
                    nameSet.add(name);
                }
            }

            // style
            if (body.s != null && !isString(body.s)) return IllegalFormat;
            final style = Nullable.of((body.s : Null<String>));

            // assets
            if (body.a != null && !isObject(body.a)) return IllegalFormat;

            // If body.a is null, return Nullable.empty()
            final assets = if (body.a == null) {
                Nullable.empty();
            } else {
                // Otherwise, create a Map and populate it
                final map = new js.lib.Map();
                for (key in Object.keys(body.a)) {
                    final value = Syntax.field(body.a, key);
                    if (key == "" || !isUint8Array(value)) return IllegalFormat;
                    map.set(key, (value : Uint8Array));
                }
                Nullable.of(map);
            }

            return Success({
                layouts: layouts,
                style: style,
                assets: assets
            });
        } catch (e) {
            return IllegalFormat;
        }
    }
}

enum UnpackYrtResult {
    Success(yrt:YrtPackage);
    IllegalFormat;
}

typedef YrtPackage = {
    /**
        レイアウトXML
    **/
    var layouts:Array<YrtLayoutEntry>;
    /**
        スタイルXML
    **/
    var style:Nullable<String>;
    /**
        アセット
    **/
    var assets:Nullable<js.lib.Map<String, Uint8Array>>;
}

typedef YrtLayoutEntry = {
    /**
        レイアウト名
        - この値はデザイナーでの表示でのみ使用されるメタデータです。
    **/
    var name:Nullable<String>;
    /**
        レイアウトXML
    **/
    var xml:String;
}

private function isInt(value:Dynamic):Bool {
    return Std.isOfType(value, Int);
}

private function isString(value:Dynamic):Bool {
    return Std.isOfType(value, String);
}

private function isObject(value:Dynamic):Bool {
    return Syntax.strictEq(Syntax.typeof(value), "object");
}

private function isArray(value:Dynamic):Bool {
    return js.Syntax.code("Array.isArray({0})", value);
}

private function isUint8Array(value:Dynamic):Bool {
    return Std.isOfType(value, Uint8Array);
}
