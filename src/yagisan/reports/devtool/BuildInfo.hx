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
        final cwd = Sys.getCwd();

        var currentDir = sys.FileSystem.fullPath(cwd);
        var packageJsonPath:String = null;
        var depth = 0;
        final maxDepth = 10;

        while (depth < maxDepth) {
            final candidatePath = Path.join([currentDir, "package.json"]);

            if (sys.FileSystem.exists(candidatePath)) {
                final fullPath = sys.FileSystem.fullPath(candidatePath);
                // Skip if it's the build/package.json
                if (fullPath.indexOf("/build/package.json") == -1 &&
                    fullPath.indexOf("\\build\\package.json") == -1) {
                    packageJsonPath = fullPath;
                    break;
                }
            }

            // Move to parent directory
            final parentDir = Path.directory(currentDir);
            if (parentDir == currentDir) {
                // Reached the root directory
                break;
            }
            currentDir = parentDir;
            depth++;
        }
        if (packageJsonPath == null) {
            Context.error('package.json not found. Started from: $cwd', Context.currentPos());
        }

        Context.registerModuleDependency(Context.getLocalModule(), packageJsonPath);

        final content = File.getContent(packageJsonPath);
        final packageData:Dynamic = Json.parse(content);
        final version:String = packageData.version;
        if (version == null) {
            Context.error("version field not found in package.json", Context.currentPos());
        }

        return macro $v{version};
    }
}
