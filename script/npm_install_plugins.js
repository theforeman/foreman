const { spawnSync } = require('./npm_spawn');
const { packageJsonDirs } = require('./plugin_webpack_directories');

const installPlugin = pluginPath =>
  spawnSync({
    command: 'npm',
    commandArgs: ['install', '--no-save', pluginPath],
  });

const installPluginDeps = pluginPath =>
  spawnSync({
    command: 'npm',
    commandArgs: ['install'],
    cwd: pluginPath,
  });

packageJsonDirs('pipe').forEach(pluginPath => {
  installPluginDeps(pluginPath);
  installPlugin(pluginPath);
});
