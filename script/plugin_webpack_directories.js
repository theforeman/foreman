'use strict';
/* eslint-disable no-var*/

var execSync = require('child_process').execSync;
var path = require('path');

// If we get multiple lines, then the plugin_webpack_directories.rb script
// has on the stdout more that just the JSON we want, so we use newline to split and check.
var sanitizeWebpackDirs = function (pluginDirs) {
  var splitDirs = pluginDirs.toString().split('\n').reverse();

  return splitDirs.length > 2 ? splitDirs[1] : pluginDirs;
};

var webpackDirs = execSync(path.join(__dirname, './plugin_webpack_directories.rb'), {
  stdio: ['pipe', 'pipe', 'ignore']
});

module.exports = JSON.parse(sanitizeWebpackDirs(webpackDirs));
