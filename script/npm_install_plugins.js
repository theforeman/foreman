'use strict';
/* eslint-disable no-var */
var childProcess = require('child_process');
var packageJsonDirs = require('./plugin_webpack_directories').packageJsonDirs;

packageJsonDirs().forEach(function(pluginPath) {
  childProcess.spawn('npm', ['i'], {
    env: process.env,
    cwd: pluginPath,
    stdio: 'inherit',
  });
});
