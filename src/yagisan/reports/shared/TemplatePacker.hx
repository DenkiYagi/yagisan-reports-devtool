package yagisan.reports.shared;

import extype.Tuple.Tuple2;
import js.Syntax;
import js.lib.Object;
import js.lib.Uint8Array;
import js.npm.msgpack.MsgPack;

/**
    テンプレートをパッケージングします。
**/
function packTemplate(layoutXml:String, ?assets:Dynamic<Uint8Array>):Uint8Array {
    final assetItems = [];
    if (assets != null) {
        for (k in Object.keys(cast assets)) {
            final v = Syntax.field(assets, k);
            if (!Std.isOfType(v, Uint8Array)) {
                throw 'アセットにUint8Array以外の値が設定されています。 id="${k}"';
            }

            if (v != null) {
                assetItems.push(new Tuple2(k, v));
            }
        }
    }

    return if (assetItems.length > 0) {
        MsgPack.encode(untyped [layoutXml, Lambda.fold(assetItems, (x, acc:{}) -> {
            Reflect.setField(acc, x.value1, x.value2);
            acc;
        }, {})]);
    } else {
        MsgPack.encode([layoutXml]);
    }
}

/**
    パッケージングされたテンプレートを展開します。
**/
function unpackTemplate(yrt:Uint8Array):UnpackedTemplate {
    final result:Array<Any> = try {
        MsgPack.decode(yrt);
    } catch (e) {
        throw createTemplateFormatError();
    }

    if (result.length == 0 || result.length > 2) throw createTemplateFormatError();

    final xml:Any = result[0];
    if (!Std.isOfType(result[0], String) || result[0] == "") throw createTemplateFormatError();

    final assets = new extype.Map();
    if (result[1] != null) {
        if (!Std.isOfType(result[1], Object)) throw createTemplateFormatError();

        final obj = result[1];
        for (key in Object.keys(obj)) {
            final value = Syntax.field(obj, key);
            if (!Std.isOfType(value, Uint8Array)) throw createTemplateFormatError();
            assets.set(key, (value : Uint8Array));
        }
    }

    return {
        layoutXml: xml,
        assets: assets
    };
}

private inline function createTemplateFormatError() {
    return "テンプレートデータの形式が不正です。";
}

typedef UnpackedTemplate = {
    final layoutXml:String;
    final assets:extype.Map<String, Uint8Array>;
}
