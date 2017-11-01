'use strict';
/* eslint-disable no-var*/

var execSync = require('child_process').execSync;
var path = require('path');
var fs = require('fs');

// If we get multiple lines, then the plugin_webpack_directories.rb script
// has on the stdout more that just the JSON we want, so we use newline to split and check.
var sanitizeWebpackDirs = function(pluginDirs) {
  var splitDirs = pluginDirs
    .toString()
    .split('\n')
    .reverse();

  return splitDirs.length > 2 ? splitDirs[1] : pluginDirs;
};

// Get paths that have a specific file or folder
var pluginPath = function(file) {
  return function(pluginsObj) {
    var paths = [];

    pluginsObj.paths.forEach(function(entry) {
      var filePath = path.join(path.dirname(entry), file);

      if (fs.existsSync(filePath)) {
        paths.push(filePath);
      }
    });
    return paths;
  };
};

// Create aliases for plugins so that their components are easily accessible.
// Each alias points to /$path_to_plugin/webpack
var aliasPlugins = function(pluginEntries) {
  var aliases = {};

  Object.keys(pluginEntries).forEach(function(key) {
    aliases[key] = path.dirname(pluginEntries[key]);
  });
  return aliases;
};

var webpackedDirs = function() {
  return execSync(path.join(__dirname, './plugin_webpack_directories.rb'), {
    stdio: ['pipe', 'pipe', 'ignore'],
  });
};

var getPluginDirs = function() {
  return JSON.parse(sanitizeWebpackDirs(webpackedDirs()));
};

var packageJsonDirs = function() {
  return pluginPath('package.json')(getPluginDirs()).map(path.dirname);
};

module.exports = {
  getPluginDirs: getPluginDirs,
  pluginNodeModules: pluginPath('node_modules'),
  aliasPlugins: aliasPlugins,
  packageJsonDirs: packageJsonDirs,
  sanitizeWebpackDirs: sanitizeWebpackDirs,
  pluginPath: pluginPath,
};
