#!/usr/bin/env node
import { execSync } from "child_process";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const buildDir = __dirname;
const rootDir = path.resolve(__dirname, "..");

console.log("Starting build process...\n");

// Step 1: Ensure build dependencies are installed
console.log("1/3 Installing build dependencies...");
try {
  execSync("yarn install --frozen-lockfile", {
    cwd: buildDir,
    stdio: "inherit"
  });
} catch (error) {
  console.error("Failed to install build dependencies");
  process.exit(1);
}

// Step 2: Run Haxe compilation
console.log("\n2/3 Compiling Haxe source...");
const libDir = path.join(rootDir, "lib");
if (!fs.existsSync(libDir)) {
  fs.mkdirSync(libDir, { recursive: true });
}

try {
  execSync("haxe compile.hxml", {
    cwd: buildDir,
    stdio: "inherit"
  });
} catch (error) {
  console.error("Haxe compilation failed");
  process.exit(1);
}

// Step 3: Run esbuild bundling
console.log("\n3/3 Bundling with esbuild...");
try {
  execSync(`node build/bundle.mjs`, {
    cwd: rootDir,
    stdio: "inherit"
  });
} catch (error) {
  console.error("esbuild bundling failed");
  process.exit(1);
}

console.log("\nBuild completed successfully!");
console.log(`Output: ${path.join(rootDir, "bin/main.js")}`);
