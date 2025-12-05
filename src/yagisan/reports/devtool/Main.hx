package yagisan.reports.devtool;

import js.Node.process;
import js.npm.Commander;
import js.npm.Commander.InvalidArgumentError;
import yagisan.reports.devtool.BuildInfo;
import yagisan.reports.devtool.command.GlyphdataCommand;
import yagisan.reports.devtool.command.YrtAlphaCommand;
import yagisan.reports.devtool.command.YrtCommand;

private function handleAsyncAction(action:haxe.Constraints.Function):haxe.Constraints.Function {
    return js.Syntax.code('function(...args) {
        const promise = {0}(...args);
        if (promise && typeof promise.then === "function") {
            promise.catch((error) => {
                if (typeof error === "string") {
                    console.error(error);
                } else if (error instanceof Error) {
                    console.error(error.message);
                } else {
                    console.error("An error occurred");
                }
                process.exit(1);
            });
        }
    }', action);
}

function main() {
    final program = new Command()
        .name("yagisan")
        .version(BuildInfo.getVersion());

    // --------------------------------
    // yrt command
    // --------------------------------
    final yrt = program.command("yrt")
        .description("YRT Manipulation");

    yrt.command("pack")
        .description("Create a YRT file from XML files and any assets")
        .argument("<xml...>", "XML file (usage: `/path/to/xml` or `/path/to/xml@name`)")
        .option("-A, --asset <file>", "Append asset file (usage: `--asset /path/to/asset@name`)", (value, previous) -> {
            previous != null ? previous.concat([value]) : [value];
        })
        .option("-S, --style <file>", "Append style xml file (usage: `--style /path/to/style`)", (value, previous) -> {
            if (previous != null) {
                final args = js.Node.process.argv;
                final optionName = args.indexOf("--style") >= 0 ? "--style" : "-S";
                throw new InvalidArgumentError('Option $optionName can only be specified once');
            }
            value;
        })
        .requiredOption("-O, --out <file>", "Set output file path", (value, previous) -> {
            if (previous != null) {
                final args = js.Node.process.argv;
                final optionName = args.indexOf("--out") >= 0 ? "--out" : "-O";
                throw new InvalidArgumentError('Option $optionName can only be specified once');
            }
            value;
        })
        .helpOption("-h, --help", "Display help for command")
        .action(handleAsyncAction((xmls, options) -> {
            yrtPack({
                xmlPaths: xmls,
                assets: options.asset != null ? options.asset : [],
                style: options.style,
                outputPath: options.out,
            });
        }));

    yrt.command("unpack")
        .description("Extract contents from a YRT file")
        .argument("<yrt>", "YRT file path")
        .option("-D, --dest <directory>", "Output directory (default: same as YRT file)")
        .helpOption("-h, --help", "Display help for command")
        .action(handleAsyncAction((yrt, options) -> {
            yrtUnpack({
                yrtPath: yrt,
                destDir: options.dest,
            });
        }));

    // --------------------------------
    // yrt-alpha command
    // --------------------------------
    final yrtAlpha = program.command("yrt-alpha")
        .description("YRT Manipulation (legacy format for <= v1.0.0-alpha.13)");

    yrtAlpha.command("pack")
        .description("Create a YRT file from an XML file and any assets")
        .argument("<xml>", "XML file path")
        .option("-A, --asset <file>", "Append asset (usage: `--asset /path/to/asset@name`)", (value, previous) -> {
            previous != null ? previous.concat([value]) : [value];
        })
        .option("-O, --out <file>", "Set output file path", (value, previous) -> {
            if (previous != null) {
                final args = js.Node.process.argv;
                final optionName = args.indexOf("--out") >= 0 ? "--out" : "-O";
                throw new InvalidArgumentError('Option $optionName can only be specified once');
            }
            value;
        })
        .helpOption("-h, --help", "Display help for command")
        .action(handleAsyncAction((xml, options) -> {
            yrtAlphaPack({
                xmlPath: xml,
                assets: options.asset != null ? options.asset : [],
                outputPath: options.out,
            });
        }));

    yrtAlpha.command("unpack")
        .description("Extract contents from a YRT file")
        .argument("<yrt>", "YRT file path")
        .option("-D, --dest <directory>", "Output directory (default: same as YRT file)")
        .helpOption("-h, --help", "Display help for command")
        .action(handleAsyncAction((yrt, options) -> {
            yrtAlphaUnpack({
                yrtPath: yrt,
                destDir: options.dest,
            });
        }));

    // --------------------------------
    // glyphdata command
    // --------------------------------
    final glyphdata = program.command("glyphdata")
        .description("Glyphdata Manipulation");

    glyphdata.command("generate")
        .description("Generate glyphdata from a font file")
        .argument("<font>", "Font file path")
        .option("-O, --out <file>", "Set output file path")
        .helpOption("-h, --help", "Display help for command")
        .action(handleAsyncAction((font, options) -> {
            glyphdataGenerate({
                fontPath: font,
                outputPath: options.out,
            });
        }));

    program.parse(process.argv);
}
