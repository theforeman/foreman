#!/usr/bin/env node

process.stdout.write(
  require('./plugin_webpack_directories')
    .getPluginDirs()
    .paths.join(' ')
);
