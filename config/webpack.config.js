/* eslint-disable no-var*/
'use strict';

var path = require('path');
var webpack = require('webpack');
var UglifyJsPlugin = require('uglifyjs-webpack-plugin');
var StatsWriterPlugin = require("webpack-stats-plugin").StatsWriterPlugin;
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CompressionPlugin = require('compression-webpack-plugin');
var LodashModuleReplacementPlugin = require('lodash-webpack-plugin');
var pluginUtils = require('../script/plugin_webpack_directories');
var vendorEntry = require('./webpack.vendor');
var SimpleNamedModulesPlugin = require('../webpack/simple_named_modules');

module.exports = env => {
  // must match config.webpack.dev_server.port
  var devServerPort = 3808;

  // set TARGETNODE_ENV=production on the environment to add asset fingerprints
  var production =
    process.env.RAILS_ENV === 'production' ||
    process.env.NODE_ENV === 'production';

  var bundleEntry = path.join(__dirname, '..', 'webpack/assets/javascripts/bundle.js');

  var plugins = pluginUtils.getPluginDirs('pipe');

  var resolveModules = [  path.join(__dirname, '..', 'webpack'),
                          path.join(__dirname, '..', 'node_modules'),
                          'node_modules/',
                       ].concat(pluginUtils.pluginNodeModules(plugins));

  if (env && env.pluginName !== undefined) {
    var pluginEntries = {};
    pluginEntries[env.pluginName] = plugins['entries'][env.pluginName];
    var outputPath = path.join(plugins['plugins'][env.pluginName]['root'], 'public', 'webpack');
    var jsFilename = production ? env.pluginName + '/[name]-[chunkhash].js' : env.pluginName + '/[name].js';
    var cssFilename = production ? env.pluginName + '/[name]-[chunkhash].css' : env.pluginName + '/[name].css';
    var manifestFilename = env.pluginName + '/manifest.json';
  } else {
    var pluginEntries = plugins['entries'];
    var outputPath = path.join(__dirname, '..', 'public', 'webpack');
    var jsFilename = production ? '[name]-[chunkhash].js' : '[name].js';
    var cssFilename = production ? '[name]-[chunkhash].css' : '[name].css';
    var manifestFilename = 'manifest.json';
  }

  var entry = Object.assign(
    {
      bundle: bundleEntry,
      vendor: vendorEntry,
    },
    pluginEntries
  );

  var config = {
    entry: entry,
    output: {
      // Build assets directly in to public/webpack/, let webpack know
      // that all webpacked assets start with webpack/

      // must match config.webpack.output_dir
      path: outputPath,
      publicPath: '/webpack/',
      filename: jsFilename
    },

    resolve: {
      modules: resolveModules,
      alias: Object.assign({
        foremanReact:
          path.join(__dirname,
             '../webpack/assets/javascripts/react_app'),
        },
        pluginUtils.aliasPlugins(pluginEntries)
      )
    },

    module: {
      rules: [
        {
          test: /\.js$/,
          // Include novnc in webpack, transpiling is needed for phantomjs (which does not support ES6) to run tests
          exclude: /node_modules(?!\/@novnc)/,
          loader: 'babel-loader',
          options: {
            'presets': [
              path.join(__dirname, '..', 'node_modules/babel-preset-react'),
              path.join(__dirname, '..', 'node_modules/babel-preset-env')
            ],
            'plugins': [
              path.join(__dirname, '..', 'node_modules/babel-plugin-transform-class-properties'),
              path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-rest-spread'),
              path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-assign'),
              path.join(__dirname, '..', 'node_modules/babel-plugin-lodash')
            ]
          }
        },
        {
          test: /\.css$/,
          use: ExtractTextPlugin.extract({
            fallback: 'style-loader',
            use: 'css-loader'
          })
        },
        {
          test: /(\.png|\.gif)$/,
          use: 'url-loader?limit=32767'
        },
        {
          test: /\.scss$/,
          use: ExtractTextPlugin.extract({
            fallback: 'style-loader', // The backup style loader
            use: production ? 'css-loader!sass-loader' : 'css-loader?sourceMap!sass-loader?sourceMap'
          })
        }
      ]
    },

    plugins: [
      new LodashModuleReplacementPlugin({
        paths: true,
        collections: true,
        flattening: true,
        shorthands: true
      }),
      // must match config.webpack.manifest_filename
      new StatsWriterPlugin({
        filename: manifestFilename,
        fields: null,
        transform: function (data, opts) {
          return JSON.stringify(
            {
              assetsByChunkName: data.assetsByChunkName,
              errors: data.errors,
              warnings: data.warnings
            }, null, 2 );
        }
      }),
      new ExtractTextPlugin({
        filename: cssFilename,
        allChunks: true
      }),
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: JSON.stringify(production ? 'production' : 'development'),
          NOTIFICATIONS_POLLING: process.env.NOTIFICATIONS_POLLING
        }
      }),
    ]
  };

  config.plugins.push(new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks: Infinity,
  }))

  if (production) {
    config.plugins.push(
      new webpack.NoEmitOnErrorsPlugin(),
      new UglifyJsPlugin({
        uglifyOptions: {
          compress: { warnings: false },
        },
        sourceMap: true
      }),
      new SimpleNamedModulesPlugin(),
      new webpack.optimize.ModuleConcatenationPlugin(),
      new webpack.optimize.OccurrenceOrderPlugin(),
      new CompressionPlugin()
    );
    config.devtool = 'source-map';
  } else {
    config.plugins.push(
      new webpack.HotModuleReplacementPlugin() // Enable HMR
    );
    var result = require('dotenv').config();
    if (result.error && result.error.code !== 'ENOENT') {
      throw result.error;
    }

    config.devServer = {
      host: process.env.BIND || 'localhost',
      port: devServerPort,
      headers: { 'Access-Control-Allow-Origin': '*' },
      hot: true
    };
    // Source maps
    config.devtool = 'inline-source-map';
  }

  return config;
}
