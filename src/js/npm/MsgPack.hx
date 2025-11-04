package js.npm;

import haxe.extern.EitherType;
import js.lib.ArrayBuffer;
import js.lib.ArrayBufferView;
import js.lib.Iterator;
import js.lib.Promise;
import js.lib.Uint8Array;

#if jsImport
@:js.import(@star "@msgpack/msgpack")
#else
@:jsRequire("@msgpack/msgpack")
#end
extern class MsgPack {
	static function encode(data:Any, ?options:EncodeOptions):Uint8Array;
	static function decode(buffer:EitherType<Array<Int>, EitherType<ArrayBufferView, ArrayBuffer>>, ?options:DecodeOptions):Any;

	// TODO AsyncIterable, ReadableStream support
	static function decodeAsync(stream:Dynamic, ?options:DecodeOptions):Promise<Any>;
	static function decodeArrayStream(stream:Dynamic, ?options:DecodeOptions):AsyncIterator<Any>;
	static function decodeStream(stream:Dynamic, ?options:DecodeOptions):AsyncIterator<Any>;
}

typedef EncodeOptions = {
	var ?extensionCodec:ExtensionCodec<Any>;
	var ?maxDepth:Int;
	var ?initialBufferSize:Int;
	var ?sortKeys:Bool;
	var ?forceFloat32:Bool;
	var ?forceIntegerToFloat:Bool;
	var ?ignoreUndefined:Bool;
	var ?context:Any;
}

typedef DecodeOptions = {
	var ?extensionCodec:ExtensionCodec<Any>;
	var ?maxStrLength:Int;
	var ?maxBinLength:Int;
	var ?maxArrayLength:Int;
	var ?maxMapLength:Int;
	var ?maxExtLength:Int;
	var ?context:Any;
}

typedef ExtensionEncoder<TContextType> = (input:Any, context:TContextType) -> Null<Uint8Array>;
typedef ExtensionDecoder<TContextType> = (data:Uint8Array, extensionType:Int, context:TContextType) -> Any;

#if jsImport
@:js.import("@msgpack/msgpack", "ExtensionCodec")
#else
@:jsRequire("@msgpack/msgpack", "ExtensionCodec")
#end
extern class ExtensionCodec<TContextType> {
	static final defaultCodec:ExtensionCodec<Dynamic>;

	function new();
	function register(def:{type:Int, encode:ExtensionEncoder<TContextType>, decode:ExtensionDecoder<TContextType>}):Void;
}
