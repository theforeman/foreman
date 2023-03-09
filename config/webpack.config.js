/* eslint-disable no-var*/
'use strict';

var path = require('path');
var webpack = require('webpack');


var ForemanVendorPlugin = require('@theforeman/vendor')
  .WebpackForemanVendorPlugin;
var StatsWriterPlugin = require('webpack-stats-plugin').StatsWriterPlugin;
var MiniCssExtractPlugin = require('mini-css-extract-plugin');
var CompressionPlugin = require('compression-webpack-plugin');
// var pluginUtils = require('../script/plugin_webpack_directories');
var vendorEntry = require('./webpack.vendor');
var SimpleNamedModulesPlugin = require('../webpack/simple_named_modules');
var argvParse = require('argv-parse');
var fs = require('fs');
var CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const { env } = require('process');
const { ModuleFederationPlugin } = require('webpack').container;



// var args = argvParse({
//   port: {
//     type: 'string',
//   },
//   host: {
//     type: 'string',
//   },
// });

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

// const devServerConfig = () => {
//   const result = require('dotenv').config();
//   if (result.error && result.error.code !== 'ENOENT') {
//     throw result.error;
//   }

//   return {
//     port: args.port || '3808',
//     host: args.host || process.env.BIND || 'localhost',
//   };
// };

// // module.exports = env => {
// //   const devServer = devServerConfig();

// //   // set TARGETNODE_ENV=production on the environment to add asset fingerprints
// //   var production =
// //     process.env.RAILS_ENV === 'production' ||
// //     process.env.NODE_ENV === 'production';

// //   const devMode = !production;
// //   var bundleEntry = path.join(
// //     __dirname,
// //     '..',
// //     'webpack/assets/javascripts/bundle.js'
// //   );

// //   var plugins = pluginUtils.getPluginDirs('pipe');

// //   var resolveModules = [
// //     path.join(__dirname, '..', 'webpack'),
// //     path.join(__dirname, '..', 'node_modules'),
// //     'node_modules/',
// //   ].concat(pluginUtils.pluginNodeModules(plugins));

// //   if (env && env.pluginName !== undefined) {
// //     var pluginEntries = {};
// //     pluginEntries[env.pluginName] = plugins['entries'][env.pluginName];
// //     for (var entry of Object.keys(plugins['entries'])) {
// //       if (entry.startsWith(env.pluginName + ':')) {
// //         pluginEntries[entry] = plugins['entries'][entry];
// //       }
// //     }

// //     var outputPath = path.join(
// //       plugins['plugins'][env.pluginName]['root'],
// //       'public',
// //       'webpack'
// //     );
// //     var jsFilename = production
// //       ? env.pluginName + '/[name]-[fullhash].js'
// //       : env.pluginName + '/[name].js';
// //     var chunkFilename = production
// //       ? env.pluginName + '/[name]-[fullhash].js'
// //       : env.pluginName + '/[name].js';
// //     var manifestFilename = env.pluginName + '/manifest.json';
// //   } else {
// //     var pluginEntries = plugins['entries'];
// //     var outputPath = path.join(__dirname, '..', 'public', 'webpack');
// //     var jsFilename = production ? '[name]-[fullhash].js' : '[name].js';
// //     var cssFilename = production ? '[name]-[fullhash].css' : '[name].css';
// //     var cssChunkFilename = production ? '[id]-[fullhash].css' : '[id].css';
// //     var chunkFilename = production ? '[name]-[fullhash].js' : '[name].js';
// //     var manifestFilename = 'manifest.json';
// //   }

// //   var entry = Object.assign(
// //     {
// //       bundle: bundleEntry,
// //       vendor: vendorEntry,
// //     },
// //     pluginEntries
// //   );

// //   const supportedLanguagesRE = new RegExp(
// //     `/(${supportedLanguages().join('|')})$`
// //   );
// //   const mode = production ? 'production' : 'development';
// //   var config = {
// //     stats: 'verbose',
// //     optimization: {
// //       minimize: true, //enable css-minimizer-webpack-plugin also in dev
// //       chunkIds: 'named', //make sure we use names as chunk ids to dedup dependencies
// //     },
// //     entry: entry,
// //     mode,
// //     output: {
// //       // Build assets directly in to public/webpack/, let webpack know
// //       // that all webpacked assets start with webpack/

// //       // must match config.webpack.output_dir
// //       path: outputPath,
// //       publicPath: '/webpack/',
// //       filename: jsFilename,
// //       chunkFilename,
// //     },

// //     resolve: {
// //       modules: resolveModules,
// //       alias: Object.assign(
// //         {
// //           foremanReact: path.join(
// //             __dirname,
// //             '../webpack/assets/javascripts/react_app'
// //           ),
// //         },
// //         pluginUtils.aliasPlugins(pluginEntries)
// //       ),
// //     },

// //     module: {
// //       rules: [
// //         {
// //           test: /\.js$/,
// //           /* Include novnc, unidiff in webpack, transpiling is needed for phantomjs (which does not support ES6) to run tests
// //           unidiff can be removed once https://github.com/mvoss9000/unidiff/pull/1 is merged */
// //           exclude: /node_modules(?!\/(@novnc|unidiff))/,
// //           loader: 'babel-loader',
// //           options: {
// //             presets: [require.resolve('@theforeman/builder/babel')],
// //           },
// //         },
// //         {
// //           test: /\.(sa|sc|c)ss$/,
// //           use: [
// //             {
// //               loader: MiniCssExtractPlugin.loader,
// //               // options: {
// //               //   filename: cssFilename,
// //               //   chunkFilename: cssChunkFilename,
// //               // }
// //             },
// //             // 'style-loader',
// //             'css-loader',
// //             // 'postcss-loader',
// //             'sass-loader',
// //           ],
// //         },
// //         {
// //           test: /\.(png|gif|svg)$/,
// //           use: 'url-loader?limit=32767',
// //         },
// //         {
// //           test: /\.(graphql|gql)$/,
// //           exclude: /node_modules/,
// //           loader: 'graphql-tag/loader',
// //         },
// //       ],
// //     },

// //     plugins: [
// //       new ForemanVendorPlugin({
// //         mode,
// //       }),
// //       // must match config.webpack.manifest_filename
// //       new StatsWriterPlugin({
// //         filename: manifestFilename,
// //         fields: null,
// //         transform: function(data, opts) {
// //           return JSON.stringify(
// //             {
// //               assetsByChunkName: data.assetsByChunkName,
// //               errors: data.errors,
// //               warnings: data.warnings,
// //             },
// //             null,
// //             2
// //           );
// //         },
// //       }),
// //       new CssMinimizerPlugin({
// //         minimizerOptions: {
// //           preset: [
// //             'default',
// //             {
// //               discardComments: { removeAll: true },
// //             },
// //           ],
// //         },
// //       }),
// //       new webpack.DefinePlugin({
// //         'process.env': {
// //           NODE_ENV: JSON.stringify(mode),
// //           NOTIFICATIONS_POLLING: process.env.NOTIFICATIONS_POLLING,
// //           REDUX_LOGGER: process.env.REDUX_LOGGER,
// //         },
// //       }),
// //       // limit locales from intl only to supported ones
// //       new webpack.ContextReplacementPlugin(
// //         /intl\/locale-data\/jsonp/,
// //         supportedLanguagesRE
// //       ),
// //       // limit locales from react-intl only to supported ones
// //       new webpack.ContextReplacementPlugin(
// //         /react-intl\/locale-data/,
// //         supportedLanguagesRE
// //       ),
// //       new MiniCssExtractPlugin(),
// //       new webpack.ProgressPlugin({
// // 	        activeModules: true,
// //   entries: true,
// //   modules: true,
// //   modulesCount: 5000,
// //   profile: true,
// //   dependencies: true,
// //   dependenciesCount: 10000,
// //   percentBy: null,
// //       }),
// // //new webpack.debug.ProfilingPlugin({
// // //  outputPath: path.join(__dirname, 'profileEvents.json'),
// // //}),
// //     ].concat(
// //       devMode ? [] : [new MiniCssExtractPlugin()]
// //     ),
// //   };

// //   if (production) {
// //     config.plugins.push(
// // //      new TerserPlugin({
// // //        terserOptions: {
// // //          compress: { warnings: false },
// // //        },
// // //        sourceMap: true,
// // //      }),
// //       new SimpleNamedModulesPlugin(),
// //       new CompressionPlugin()
// //     );
// //     config.devtool = 'source-map';
// //   } else {
// //     config.plugins.push(
// //       new webpack.HotModuleReplacementPlugin() // Enable HMR
// //     );

// //     config.devServer = {
// //       host: devServer.host,
// //       port: devServer.port,
// //       headers: { 'Access-Control-Allow-Origin': '*' },
// //       devMiddleware: {
// //         stats: process.env.WEBPACK_STATS || 'minimal',
// //       },
// //     };
// //     // Source maps
// //     config.devtool = 'inline-source-map';
// //   }

// // const logging = require('webpack/lib/logging/runtime');
// // var logger = logging.getLogger('ZZZLOGGERZZZ');
// // logger.info(config);

// //   return config;
// // };

const supportedLanguagesRE = new RegExp(
  `/(${supportedLanguages().join('|')})$`
);

var bundleEntry = path.join(
  __dirname,
  '..',
  'webpack/assets/javascripts/bundle.js'
);

const commonConfig = function(env, argv) {
  var production =
    process.env.RAILS_ENV === 'production' ||
    process.env.NODE_ENV === 'production';
  const mode = production ? 'production' : 'development';
  return {
    mode,
    resolve:{
      fallback: {
        path: require.resolve("path-browserify"),
        os: require.resolve("os-browserify")
      },
      alias: {
        foremanReact: path.join(__dirname, '../webpack/assets/javascripts/react_app'),
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
          test: /\.(sa|sc|c)ss$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
            },
            'css-loader',
            'sass-loader',
          ],
        },
        {
          test: /\.(png|gif|svg)$/,
          type: 'asset',
          parser: {
            dataUrlCondition: {
              maxSize: 32767,
            }
          }
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
      new MiniCssExtractPlugin(),
      new ModuleFederationPlugin({
        name: 'foreman-core',
        shared: {
          react: { singleton: true },
          'react-dom': { singleton: true },
          moment: { singleton: true },
        },
      }),
    ],
    infrastructureLogging: {
      colors: true,
      level: 'verbose',
    },
    stats: {
      logging: 'verbose',
      preset: 'verbose',
    },
  };
};

const moduleFederationSharedConfig = function(env, argv) {
  return {
    react: { singleton: true },
    'react-dom': { singleton: true },
    '@theforeman/vendor': { singleton: true },
  }
};

const coreConfig = function(env, argv) {
  var config = commonConfig(env, argv);
  config.context = path.resolve(__dirname, '..');
  config.entry = {
    bundle: { import: bundleEntry, dependOn: 'vendor' },
    vendor: vendorEntry,
  };
  config.output = {
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',
    filename: '[name].js',
    chunkFilename: '[name].js',
  };
  var plugins = config.plugins;
  plugins.push(
    new ModuleFederationPlugin({
      name: 'foreman-core',
      shared: moduleFederationSharedConfig(env, argv),
    }));
  config.plugins = plugins;
  return config;
};


const pluginConfig = function(env, argv) {
  var pluginEnv = env.plugin;
  var pluginEntries = {
    "./index": "./index.js"
  };
  pluginEnv.entries?.split(',').forEach(entry => {
    pluginEntries[entry] = entry + "_index.js";
  });
  var config = commonConfig(env, argv);
  config.context = path.join(pluginEnv.root, 'webpack');
  config.entry = {
    index: './index.js',
  };
  config.output = {
    path: path.join(pluginEnv.root, 'public', 'webpack'),
    publicPath: '/webpack/',
    filename: pluginEnv.name + ('/[name].js'),
    chunkFilename: pluginEnv.name + ('/[name].js'),
  };

  var configModules = config.resolve.modules || [];
  // make webpack to resolve modules from core first
  configModules.unshift(path.resolve(__dirname, '..', 'node_modules'));
  // add plugin's node_modules to the reslver list
  configModules.push(path.resolve(pluginEnv.root, 'node_modules'));
  config.resolve.modules = configModules;

  //get the list of webpack plugins
  var plugins = config.plugins;
  plugins.push(
    new ModuleFederationPlugin({
      name: pluginEnv.name,
      shared: moduleFederationSharedConfig(env, argv),
      remotes: pluginEntries,
    }));
  config.plugins = plugins;
  return config;
};

module.exports = function(env, argv) {
  if (env && env.plugin !== undefined) {
    return pluginConfig(env, argv);
  }

  return coreConfig(env, argv);
};
