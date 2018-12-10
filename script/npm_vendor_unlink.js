#!/usr/bin/env node

const path = require('path');
const { spawnSync } = require('./npm_spawn');
const { packageJsonDirs } = require('./plugin_webpack_directories');

const rootPath = path.join(__dirname, '..');
const theforemanVendorPath = path.join(rootPath, 'webpack/@theforeman/vendor');

// rm -rf node_modules package-lock.json
const cleanNodeModules = cwd =>
  spawnSync({
    command: 'rm',
    commandArgs: ['-rf', 'node_modules', 'package-lock.json'],
    cwd,
  });

// npm unlink
const npmUnlink = cwd =>
  spawnSync({
    command: 'npm',
    commandArgs: ['unlink'],
    cwd,
  });

// npm unlink --no-save @theforeman/vendor
const npmUnlinkVendor = cwd =>
  spawnSync({
    command: 'npm',
    commandArgs: ['unlink', '--no-save', '@theforeman/vendor'],
    cwd,
  });

npmUnlinkVendor(rootPath);
cleanNodeModules(rootPath);

packageJsonDirs('pipe').forEach(dir => {
  npmUnlinkVendor(dir);
  cleanNodeModules(dir);
});

npmUnlink(theforemanVendorPath);

spawnSync({
  command: 'npm',
  commandArgs: ['install'],
  cwd: rootPath,
});
