package js.npm.yargs;

import js.lib.Promise;
import extype.extern.ValueOrArray;
import extype.extern.Mixed;

@:jsRequire("yargs")
extern class YArgs {
    @:selfCall
    static function yargs(?processArgs:ValueOrArray<String>, ?cwd:String, ?parentRequire:Dynamic):Dynamic;
}


extern class Parser {
    function alias(key:String, alias:String):Parser;

    function parse():Dynamic;

    @:overload(function (cmd:String, desc:String, ?builder:BuilderCallback):Parser {})
    function command(cmd:String, desc:String, ?builder:Parser->Parser):Parser;

    function scriptName(name:String):Parser;

    function usage(message:String):Parser;

    @:overload(function (?enableExplicit:Bool):Parser {})
    function help(option:String, ?description:String, ?enableExplicit:Bool):Parser;
}

typedef BuilderCallback = Mixed3<
    (args:Parser)->Promise<Parser>,
    (args:Parser)->Parser,
    (args:Parser)->Void
>;
