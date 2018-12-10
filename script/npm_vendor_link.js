#!/usr/bin/env node

const path = require('path');
const { spawnSync } = require('./npm_spawn');
const { packageJsonDirs } = require('./plugin_webpack_directories');

const projectPath = path.join(__dirname, '..');
const vendorPath = path.join(projectPath, 'webpack/@theforeman/vendor');

const npmLink = (cwd = vendorPath) =>
  spawnSync({
    command: 'npm',
    commandArgs: ['link'],
    cwd,
  });

const npmLinkVendor = (cwd = projectPath) => {
  spawnSync({
    command: 'npm',
    commandArgs: ['link', '--no-save', '@theforeman/vendor'],
    cwd,
  });
};

npmLink();
npmLinkVendor();
packageJsonDirs('pipe').forEach(dir => npmLinkVendor(dir));
