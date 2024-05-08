package yagisan.reports.devtool;

import js.lib.Promise;
import yagisan.reports.devtool.command.YrtPackCommand;
import js.Node.process;
import js.Node.console;
import js.Syntax;
import js.npm.yargs.YArgs.yargs;
import js.npm.yargs.YArgsHelpers.hideBin;

function main() {
    Syntax.code("module.exports = {0}", () -> {
        final root = yargs(hideBin(process.argv))
            .scriptName("yagisan")
            .strict(true);

        root.command(
            "yrt",
            "YRT Manipulation",
            cmd -> {
                cmd.command(
                    "pack <xml>",
                    "Create a YRT file from a XML file and any assets.",
                    subcmd -> {
                        subcmd.positional("xml", {
                            describe: "XML file path",
                            type: "string",
                        });
                        subcmd.option("asset", {
                            describe: "Append asset (usage: `--asset /path/to/aseet@id`)",
                            type: "string",
                            array: true,
                            alias: ["A"],
                        });
                        subcmd.option("out", cast {
                            describe: "",
                            type: "string",
                            alias: ["O"],
                        });
                        subcmd.check((argv, options) -> yrtPackCheck({
                            xmlPath: argv.xml,
                            assets: argv.asset ?? [],
                            outputPath: argv.out,
                        }));
                    },
                    argv -> yrtPack({
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
    });
}
