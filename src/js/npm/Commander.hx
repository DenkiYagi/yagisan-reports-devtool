package js.npm;

import haxe.Constraints.Function;
import js.lib.Promise;

@:jsRequire("commander", "InvalidArgumentError")
extern class InvalidArgumentError {
    function new(message:String);
}

@:jsRequire("commander", "Command")
extern class Command {
    function new();

    function name(name:String):Command;
    function description(desc:String):Command;
    function version(version:String, ?flags:String, ?description:String):Command;

    function command(nameAndArgs:String, ?opts:Dynamic):Command;
    function argument(nameAndArgs:String, ?description:String, ?defaultValue:Dynamic):Command;

    @:overload(function(flags:String, description:String, parseFunction:Function, defaultValue:Dynamic):Command {})
    @:overload(function(flags:String, description:String, parseFunction:Function):Command {})
    @:overload(function(flags:String, description:String, defaultValue:Dynamic):Command {})
    @:overload(function(flags:String, description:String):Command {})
    function option(flags:String):Command;

    @:overload(function(flags:String, description:String, parseFunction:Function, defaultValue:Dynamic):Command {})
    @:overload(function(flags:String, description:String, parseFunction:Function):Command {})
    @:overload(function(flags:String, description:String, defaultValue:Dynamic):Command {})
    function requiredOption(flags:String, description:String):Command;

    function helpOption(flags:String, description:String):Command;

    function action(fn:Function):Command;

    function parse(?argv:Array<String>, ?options:Dynamic):Command;
    function parseAsync(?argv:Array<String>, ?options:Dynamic):Promise<Command>;

    function opts():Dynamic;
    function args():Array<String>;

    var commands:Array<Command>;
}
