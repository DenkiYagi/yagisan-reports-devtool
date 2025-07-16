package yagisan.reports.devtool;

import js.Node.process;
import js.npm.yargs.YArgs.yargs;
import js.npm.yargs.YArgsHelpers.hideBin;
import yagisan.reports.devtool.command.YrtPackCommand;

function main() {
    final root = yargs(hideBin(process.argv))
        .scriptName("yagisan")
        .strict(true)
        .parserConfiguration({
            greedyArrays: false,
        });

    root.command(
        "yrt",
        "YRT Manipulation",
        cmd -> {
            cmd.command(
                "pack <xml...>",
                "Create a YRT file from an XML file and any assets",
                subcmd -> {
                    subcmd.positional("xml", {
                        describe: "XML file (usage: `/path/to/xml` or `/path/to/xml@name`)",
                        type: String,
                        array: true
                    });
                    subcmd.option("asset", {
                        describe: "Append asset file (usage: `--asset /path/to/aseet@name`)",
                        type: String,
                        array: true,
                        alias: ["A"],
                    });
                    subcmd.option("style", {
                        describe: "Append style xml file (usage: `--style /path/to/style`)",
                        type: String,
                        alias: ["S"],
                    });
                    subcmd.option("out", {
                        describe: "Set output file path",
                        type: String,
                        alias: ["O"],
                        demandOption: true,
                    });
                    subcmd.check((argv, options) -> yrtPackCheck({
                        xmlPaths: argv.xml,
                        assets: argv.asset ?? [],
                        style: argv.style,
                        outputPath: argv.out,
                    }));
                },
                argv -> yrtPack({
                    xmlPaths: argv.xml,
                    assets: argv.asset ?? [],
                    style: argv.style,
                    outputPath: argv.out,
                })
            );

            cmd.command(
                "pack-alpha <xml>",
                "Create a YRT file from an XML file and any assets (legacy format for <= v1.0.0-alpha.13)",
                subcmd -> {
                    subcmd.positional("xml", {
                        describe: "XML file path",
                        type: String,
                    });
                    subcmd.option("asset", {
                        describe: "Append asset (usage: `--asset /path/to/aseet@id`)",
                        type: String,
                        array: true,
                        alias: ["A"],
                    });
                    subcmd.option("out", {
                        describe: "Set output file path",
                        type: String,
                        alias: ["O"],
                    });
                    subcmd.check((argv, options) -> yrtAlphaPackCheck({
                        xmlPath: argv.xml,
                        assets: argv.asset ?? [],
                        outputPath: argv.out,
                    }));
                },
                argv -> yrtAlphaPack({
                    xmlPath: argv.xml,
                    assets: argv.asset ?? [],
                    outputPath: argv.out,
                })
            );
        },
        _ -> root.showHelp()
    );

    final arguments = root.parse();
    if ((arguments?._?.length ?? Math.POSITIVE_INFINITY) <= 0) {
        root.showHelp();
    }
}
