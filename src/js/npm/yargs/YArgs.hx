package js.npm.yargs;

import extype.extern.Extern;
import extype.extern.Mixed;
import extype.extern.ValueOrArray;
import haxe.ds.ReadOnlyArray;
import js.lib.Promise;

@:jsRequire("yargs")
extern class YArgs {
    @:selfCall
    static function yargs(?processArgs:ValueOrArray<String>, ?cwd:String, ?parentRequire:Dynamic):Parser;
}

extern class Parser {
    function alias(key:String, alias:String):Parser;

    function command(cmd:String, desc:String, ?builder:BuilderCallback, ?handler:CommandHandler):Parser;

    function option(key:String, options:Options):Parser;
    function positional(key:String, opt:PositionalOptions):Parser;

    function check(func:(argv:Dynamic, aliases:Dynamic<String>)->Bool, ?global:Bool):Parser;

    function scriptName(name:String):Parser;
    function strict(?enabled:Bool):Parser;
    function parserConfiguration(config:ParserConfigurationOptions):Parser;
    function locale(locale:String):Parser;

    function usage(message:String):Parser;

    overload function help(?enableExplicit:Bool):Parser;
    overload function help(option:String, ?description:String, ?enableExplicit:Bool):Parser;

    function showHelp():Void;
    function parse():Dynamic;
}

typedef BuilderCallback = Mixed3<
    (args:Parser)->Promise<Parser>,
    (args:Parser)->Parser,
    (args:Parser)->Void
>;

typedef CommandHandler = Mixed2<
    (args:Dynamic)->Promise<Void>,
    (args:Dynamic)->Void
>;

private typedef _Configuration = {
    @:native("boolean-negation") var ?booleanNegation:Bool;
    @:native("camel-case-expansion") var ?camelCaseExpansion:Bool;
    @:native("combine-arrays") var ?combineArrays:Bool;
    @:native("dot-notation") var ?dotNotation:Bool;
    @:native("duplicate-arguments-array") var ?duplicateArgumentsArray:Bool;
    @:native("flatten-duplicate-arrays") var ?flattenDuplicateArrays:Bool;
    @:native("greedy-arrays") var ?greedyArrays:Bool;
    @:native("nargs-eats-options") var ?nargsEatsOptions:Bool;
    @:native("halt-at-non-option") var ?haltAtNonOption:Bool;
    @:native("negation-prefix") var ?negationPrefix:String;
    @:native("parse-numbers") var ?parseNumbers:Bool;
    @:native("parse-positional-numbers") var ?parsePositionalNumbers:Bool;
    @:native("populate--") var ?populateMinusMinus:Bool;
    @:native("set-placeholder-key") var ?setPlaceholderKey:Bool;
    @:native("short-option-groups") var ?shortOptionGroups:Bool;
    @:native("strip-aliased") var ?stripAliased:Bool;
    @:native("strip-dashed") var ?stripDashed:Bool;
    @:native("unknown-options-as-args") var ?unknownOptionsAsArgs:Bool;
}

typedef Configuration = Extern<_Configuration>;

typedef ParserConfigurationOptions = Extern<_Configuration & {
    @:native("sort-commands") var ?sortCommands:Bool;
}>;

typedef Options = {
    var ?alias:ValueOrArray<String>;
    var ?array:Bool;
    var ?boolean:Bool;
    var ?choices:Choices;
    var ?coerce:((arg:Dynamic)->Dynamic);
    var ?config:Bool;
    var ?configParser:((configPath:String)->Dynamic);
    var ?conflicts:Mixed2<ValueOrArray<String>, Dynamic<ValueOrArray<String>>>;
    var ?count:Bool;
    // var ?default:Dynamic;
    var ?defaultDescription:String;
    var ?deprecate:Mixed2<Bool, String>;
    var ?deprecated:Mixed2<Bool, String>;
    var ?demandOption:Mixed2<Bool, String>;
    var ?desc:String;
    var ?describe:String;
    var ?description:String;
    var ?global:Bool;
    var ?group:String;
    var ?hidden:Bool;
    var ?implies:Mixed2<ValueOrArray<String>, Dynamic<ValueOrArray<String>>>;
    var ?nargs:Int;
    var ?normalize:Bool;
    var ?number:Bool;
    var ?requiresArg:Bool;
    var ?skipValidation:Bool;
    var ?string:Bool;
    var ?type:OptionsType;
}

enum abstract OptionsType(String) {
    var Array = "array";
    var Count = "count";
    var Boolean = "boolean";
    var Number = "number";
    var String = "string";
}

typedef PositionalOptions = {
    var ?alias:ValueOrArray<String>;
    var ?array:Bool;
    var ?choices:Choices;
    var ?coerce:((arg:Dynamic)->Dynamic);
    var ?conflicts:Mixed2<ValueOrArray<String>, Dynamic<ValueOrArray<String>>>;
    // var ?default:Dynamic;
    var ?demandOption:Mixed2<Bool, String>;
    var ?desc:String;
    var ?describe:String;
    var ?description:String;
    var ?implies:Mixed2<ValueOrArray<String>, Dynamic<ValueOrArray<String>>>;
    var ?normalize:Bool;
    var ?type:PositionalOptionsType;
}

enum abstract PositionalOptionsType(String) {
    var Boolean = "boolean";
    var Number = "number";
    var String = "string";
}

typedef Choices = Array<Mixed3<String, Int, Bool>>;

