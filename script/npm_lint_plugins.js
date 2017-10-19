'use strict';
/* eslint-disable no-var */

var fs = require('fs');

var childProcess = require('child_process');
var packageJsonDirs = require('./plugin_webpack_directories').packageJsonDirs;

var pluginDefinesLint = function (pluginPath) {
  var packageData = JSON.parse(fs.readFileSync(pluginPath + '/package.json'));

  return (packageData.scripts && packageData.scripts.lint);
};

packageJsonDirs().forEach(function (pluginPath) {
  if (pluginDefinesLint(pluginPath)) {
    childProcess.spawn('npm', ['run', 'lint'], {
      env: process.env,
      cwd: pluginPath,
      stdio: 'inherit'
    });
  }
});
