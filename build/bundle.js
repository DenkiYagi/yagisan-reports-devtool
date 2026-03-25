import esbuild from "esbuild";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, "..");

// Plugin to resolve modules from build/node_modules
const buildNodeModulesPlugin = {
  name: "build-node-modules",
  setup(build) {
    build.onResolve({ filter: /@denkiyagi\/fontkit/ }, args => {
      const modulePath = path.join(__dirname, "node_modules", args.path);
      if (fs.existsSync(modulePath)) {
        const packageJsonPath = path.join(modulePath, "package.json");
        if (fs.existsSync(packageJsonPath)) {
          const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
          const entryPoint = packageJson.exports?.node?.import || packageJson.main || "index.js";
          return { path: path.join(modulePath, entryPoint) };
        }
        return { path: path.join(modulePath, "index.js") };
      }
    });
  }
};

void esbuild.build({
  entryPoints: [path.join(rootDir, "lib/yagisan-reports-devtool.js")],
  bundle: true,
  minify: true,
  platform: "node",
  target: ["node20", "es2020"],
  format: "esm",
  outfile: path.join(rootDir, "bin/main.js"),
  legalComments: "eof",
  banner: {
    js: "#!/usr/bin/env node\nvar exports = {};",
  },
  external: ["commander", "@msgpack/msgpack"],
  plugins: [buildNodeModulesPlugin],
}).catch((err) => {
  console.error("Build failed:");
  console.error(err);
  process.exit(1);
});
