#!/usr/bin/env node
/* eslint-disable no-var */

var fs = require('fs');

var childProcess = require('child_process');
var { packageJsonDirs } = require('./plugin_webpack_directories');

function pluginDefinesLint(pluginPath) {
  var packageData = JSON.parse(fs.readFileSync(`${pluginPath}/package.json`));

  return packageData.scripts && packageData.scripts.lint;
}

packageJsonDirs().forEach(pluginPath => {
  if (pluginDefinesLint(pluginPath)) {
    childProcess.spawn('pnpm', ['run', 'lint'], {
      env: process.env,
      cwd: pluginPath,
      stdio: 'inherit',
    });
  }
});
