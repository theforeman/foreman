#!/usr/bin/env node
const childProcess = require('child_process');
const { packageJsonDirs } = require('./plugin_webpack_directories');

packageJsonDirs('pipe').forEach(pluginPath => {
  childProcess.spawn('npm', ['i'], {
    env: process.env,
    cwd: pluginPath,
    stdio: 'inherit',
  });
});
