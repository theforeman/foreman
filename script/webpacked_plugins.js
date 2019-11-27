/* eslint-disable no-var */

var { execSync } = require('child_process');
var path = require('path');
var fs = require('fs');

// If we get multiple lines, then the plugin_webpack_directories.rb script
// has on the stdout more that just the JSON we want, so we use newline to split and check.
var sanitizeWebpackDirs = pluginDirs => {
  var splitDirs = pluginDirs
    .toString()
    .split('\n')
    .reverse();

  return splitDirs.length > 2 ? splitDirs[1] : pluginDirs;
};

var pluginsToBuildRB = stderr => {
  var handleStderr = stderr || 'ignore';

  return execSync(path.join(__dirname, './webpacked_plugins.rb'), {
    stdio: ['pipe', 'pipe', handleStderr],
  });
};

var webpackedPlugins = stderr =>
  JSON.parse(sanitizeWebpackDirs(pluginsToBuildRB(stderr)));

module.exports = {
  plugins: webpackedPlugins(),
};
