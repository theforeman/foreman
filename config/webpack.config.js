/* eslint-disable no-var*/
'use strict';

var path = require('path');
var webpack = require('webpack');
const dotenv = require('dotenv');
dotenv.config();
var ForemanVendorPlugin = require('@theforeman/vendor')
  .WebpackForemanVendorPlugin;
var StatsWriterPlugin = require('webpack-stats-plugin').StatsWriterPlugin;
var vendorEntry = require('./webpack.vendor');
var fs = require('fs');
const { ModuleFederationPlugin } = require('webpack').container;
var pluginUtils = require('../script/plugin_webpack_directories');

class AddRuntimeRequirement {
  // to avoid "webpackRequire.l is not a function" error
  // enables use of webpack require inside promise new promise
  apply(compiler) {
    compiler.hooks.compilation.tap('AddRuntimeRequirement', compilation => {
      const { RuntimeGlobals } = compiler.webpack;
      compilation.hooks.additionalModuleRuntimeRequirements.tap(
        'AddRuntimeRequirement',
        (module, set) => {
          set.add(RuntimeGlobals.loadScript);
        }
      );
    });
  }
}

const supportedLocales = () => {
  const localeDir = path.join(__dirname, '..', 'locale');

  // Find all files in ./locale/*
  const localesFiles = fs.readdirSync(localeDir);

  // Return only folders
  return localesFiles.filter(f =>
    fs.statSync(path.join(localeDir, f)).isDirectory()
  );
};

const supportedLanguages = () => {
  // Extract extract languages from the language tags (strip off dialects)
  return [...new Set(supportedLocales().map(d => d.split('_')[0]))];
};

const supportedLanguagesRE = new RegExp(
  `/(${supportedLanguages().join('|')})$`
);

const commonConfig = function() {
  var production =
    process.env.RAILS_ENV === 'production' ||
    process.env.NODE_ENV === 'production';
  const mode = production ? 'production' : 'development';
  const config = {};
  if (production) {
    config.devtool = 'source-map';
    config.optimization = {
      moduleIds: 'named',
      splitChunks: false,
    };
  } else {
    config.devtool = 'inline-source-map';
    config.optimization = {
      splitChunks: false,
    };
  }
  return {
    ...config,
    mode,
    resolve: {
      fallback: {
        path: require.resolve('path-browserify'),
        os: require.resolve('os-browserify'),
      },
      alias: {
        foremanReact: path.join(
          __dirname,
          '../webpack/assets/javascripts/react_app'
        ),
      },
    },
    resolveLoader: {
      modules: [path.resolve(__dirname, '..', 'node_modules')],
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          /* Include novnc, unidiff in webpack, transpiling is needed for phantomjs (which does not support ES6) to run tests
          unidiff can be removed once https://github.com/mvoss9000/unidiff/pull/1 is merged */
          exclude: /node_modules(?!\/(@novnc|unidiff))/,
          loader: 'babel-loader',
          options: {
            presets: [require.resolve('@theforeman/builder/babel')],
          },
        },
        {
          test: /\.(png|gif|svg)$/,
          type: 'asset',
          parser: {
            dataUrlCondition: {
              maxSize: 32767,
            },
          },
        },
        {
          test: /\.(graphql|gql)$/,
          exclude: /node_modules/,
          loader: 'graphql-tag/loader',
        },
      ],
    },
    plugins: [
      new ForemanVendorPlugin({
        mode,
      }),
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: JSON.stringify(mode),
          NOTIFICATIONS_POLLING: process.env.NOTIFICATIONS_POLLING,
          REDUX_LOGGER: process.env.REDUX_LOGGER,
        },
      }),
      // limit locales from intl only to supported ones
      new webpack.ContextReplacementPlugin(
        /intl\/locale-data\/jsonp/,
        supportedLanguagesRE
      ),
      // limit locales from react-intl only to supported ones
      new webpack.ContextReplacementPlugin(
        /react-intl\/locale-data/,
        supportedLanguagesRE
      ),
      new AddRuntimeRequirement(),
    ],
    stats: process.env.WEBPACK_STATS || 'normal',
  };
};

const coreConfig = function() {
  var config = commonConfig();
  var manifestFilename = 'manifest.json';
  var bundleEntry = path.join(
    __dirname,
    '..',
    'webpack/assets/javascripts/bundle.js'
  );
  config.context = path.resolve(__dirname, '..');
  config.entry = {
    bundle: { import: bundleEntry, dependOn: 'vendor' },
    vendor: vendorEntry,
  };
  config.output = {
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',
  };
  var plugins = config.plugins;

  plugins.push(
    new ModuleFederationPlugin({
      name: 'foremanReact',
    })
  );
  plugins.push(
    new StatsWriterPlugin({
      filename: manifestFilename,
    })
  );
  config.plugins = plugins;
  var rules = config.module.rules;
  rules.push({
    test: /\.(sa|sc|c)ss$/,
    use: [
      {
        loader: 'style-loader',
        options: {
          injectType: 'singletonStyleTag',
          attributes: { id: 'foreman_core_css' },
        },
      },
      'css-loader',
      'sass-loader',
    ],
  });
  config.module.rules = rules;
  return config;
};

const pluginConfig = function(plugin) {
  const pluginRoot = plugin.root;
  const pluginName = plugin.name.replace('-', '_'); // module federation doesnt like -
  var config = commonConfig();
  config.context = path.join(pluginRoot, 'webpack');
  config.entry = {};
  var pluginEntries = {
    './index': path.resolve(pluginRoot, 'webpack', 'index'),
  };
  plugin.entries.filter(Boolean).forEach(entry => {
    pluginEntries[`./${entry}_index`] = path.resolve(
      pluginRoot,
      'webpack',
      `${entry}_index`
    );
  });

  if (config.mode == 'production') {
    var outputPath = path.join(pluginRoot, 'public', 'webpack', pluginName);
  } else {
    var outputPath = path.join(
      __dirname,
      '..',
      'public',
      'webpack',
      pluginName
    );
  }
  config.output = {
    path: outputPath,
    publicPath: '/webpack/' + pluginName + '/',
    uniqueName: pluginName,
  };
  var configModules = config.resolve.modules || [];
  // make webpack to resolve modules from core first
  configModules.unshift(path.resolve(__dirname, '..', 'node_modules'));
  // add plugin's node_modules to the reslver list
  configModules.push(path.resolve(pluginRoot, 'node_modules'));
  configModules.push('node_modules/');
  config.resolve.modules = configModules;

  //get the list of webpack plugins
  var plugins = config.plugins;
  plugins.push(
    new ModuleFederationPlugin({
      name: pluginName,
      filename: pluginName + '_remoteEntry.js',
      exposes: pluginEntries,
    })
  );
  config.plugins = plugins;
  var rules = config.module.rules;
  rules.push({
    test: /\.(sa|sc|c)ss$/,
    use: [
      {
        loader: 'style-loader',
        options: {
          injectType: 'singletonStyleTag',
          attributes: { id: `${pluginName}_css` },
        },
      },
      'css-loader',
      'sass-loader',
    ],
  });
  config.module.rules = rules;

  return config;
};

module.exports = function(env, argv) {
  const { pluginName } = env;
  var pluginsDirs = pluginUtils.getPluginDirs('pipe');
  var pluginsInfo = {};
  var pluginsConfigEnv = [];
  var pluginDirKeys = Object.keys(pluginsDirs.plugins);
  if (pluginName) {
    pluginDirKeys = pluginDirKeys.filter(key => key.includes(pluginName));
  }
  pluginDirKeys.forEach(pluginDirKey => {
    const parts = pluginDirKey.split(':');
    const name = parts[0];
    const entry = parts[1];
    if (pluginsInfo[name]) {
      pluginsInfo[name].entries.push(entry);
    } else {
      pluginsInfo[name] = {
        name,
        entries: [entry],
        root: pluginsDirs.plugins[pluginDirKey].root,
      };
    }
    if (!pluginDirKey.includes(':')) {
      const keysWithExtras = pluginDirKeys.filter(key =>
        key.includes(pluginDirKey + ':')
      );
      // for example: {global: true, routes: true}
      const pluginExtras = keysWithExtras.map(key => ({
        [key.split(':')[1]]: true,
      }));
      pluginsConfigEnv.push({
        plugin: {
          ...pluginExtras,
          name: pluginDirKey,
          root: pluginsDirs.plugins[pluginDirKey].root,
        },
      });
    }
  });
  let configs = [];
  const pluginsInfoValues = Object.values(pluginsInfo);
  if (pluginsInfoValues.length > 0) {
    configs = pluginsInfoValues.map(plugin => pluginConfig(plugin));
  }
  if (pluginName) return configs;

  return [coreConfig(env, argv), ...configs];
};
