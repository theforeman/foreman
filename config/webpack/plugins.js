const path = require('path');
const pluginUtils = require('../../script/plugin_webpack_directories');

const plugins = pluginUtils.getPluginDirs();

module.exports = {
  entry: plugins.entries,
  resolve: {
    modules: pluginUtils.pluginNodeModules(plugins),
    alias: Object.assign(
      {
        foremanReact: path.join(
          __dirname,
          '../../webpack/assets/javascripts/react_app',
        ),
      },
      pluginUtils.aliasPlugins(plugins.entries),
    ),
  },
};
