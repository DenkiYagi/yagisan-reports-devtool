package yagisan.reports.devtool;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
import haxe.Json;
#end

class BuildInfo {
    public static macro function getVersion():ExprOf<String> {
        var pos = Context.currentPos();
        var cwd = Sys.getCwd();

        // Try to find the ROOT package.json (skip build/package.json)
        var possiblePaths = [
            Path.join([cwd, "..", "package.json"]),  // Parent directory (for build/)
            Path.join([cwd, "package.json"]),         // Current directory
            Path.join([cwd, "..", "..", "package.json"])
        ];

        var packageJsonPath:String = null;
        for (path in possiblePaths) {
            if (sys.FileSystem.exists(path)) {
                var fullPath = sys.FileSystem.fullPath(path);
                // Skip if it's the build/package.json
                if (fullPath.indexOf("/build/package.json") == -1 &&
                    fullPath.indexOf("\\build\\package.json") == -1) {
                    packageJsonPath = fullPath;
                    break;
                }
            }
        }

        if (packageJsonPath == null) {
            Context.error('package.json not found. Tried: ${possiblePaths.join(", ")}. CWD: $cwd', pos);
        }

        // Register the file as a dependency so changes trigger recompilation
        Context.registerModuleDependency(Context.getLocalModule(), packageJsonPath);

        var content = File.getContent(packageJsonPath);
        var packageData:Dynamic = Json.parse(content);
        var version:String = packageData.version;

        if (version == null) {
            Context.error("version field not found in package.json", pos);
        }

        return macro $v{version};
    }
}
