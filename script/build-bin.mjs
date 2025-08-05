import esbuild from "esbuild";

void esbuild.build({
  entryPoints: ["lib/yagisan-reports-devtool.js"],
  bundle: true,
  minify: true,
  platform: "node",
  target: ["node20", "es2020"],
  format: "cjs",
  outfile: "bin/main.js",
  legalComments: "eof",
  banner: {
    js: "#!/usr/bin/env node",
  },
  external: ["yargs", "@msgpack/msgpack"],
}).catch((err) => {
  console.error("Build failed:");
  console.error(err);
  process.exit(1);
});
