/* eslint-disable no-var*/
'use strict';

var path = require('path');
var webpack = require('webpack');
var StatsWriterPlugin = require("webpack-stats-plugin").StatsWriterPlugin;
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CompressionPlugin = require('compression-webpack-plugin');
var plugins = require('../script/plugin_webpack_directories');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGETNODE_ENV=production on the environment to add asset fingerprints
var production =
  process.env.RAILS_ENV === 'production' ||
  process.env.NODE_ENV === 'production';

// Create aliases for plugins so that their components are easily accessible.
// Each alias points to /$path_to_plugin/webpack
var aliasPlugins  = function (pluginEntries) {
  var aliases = {};
  Object.keys(pluginEntries).forEach(function(key) {
    var pathSplit = pluginEntries[key].split('/');
    aliases[key] = pathSplit.slice(0, pathSplit.length - 1).join('/');
  });
  return aliases;
}

var config = {
  entry: Object.assign(
    {
      bundle: './webpack/assets/javascripts/bundle.js'
    },
    plugins.entries
  ),
  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  resolve: {
    modules: [
      path.join(__dirname, '..', 'webpack'),
      'node_modules/',
      path.join(__dirname, '..', 'node_modules')
    ],
    alias: Object.assign({
      foremanReact:
        path.join(__dirname,
           '../webpack/assets/javascripts/react_app')
    },
    aliasPlugins(plugins['entries'])
    )
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          'presets': [
            path.join(__dirname, '..', 'node_modules/babel-preset-react'),
            path.join(__dirname, '..', 'node_modules/babel-preset-es2015')
          ],
          'plugins': [
            path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-rest-spread'),
            path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-assign')
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
          use: 'css-loader?sourceMap!sass-loader?sourceMap'
        })
      }
    ]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsWriterPlugin({
      filename: 'manifest.json',
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
      filename: production ? '[name]-[chunkhash].css' : '[name].css',
      allChunks: true
    }),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(production ? 'production' : 'development'),
        NOTIFICATIONS_POLLING: process.env.NOTIFICATIONS_POLLING
      }
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor'
    })

  ]
};

if (production) {
  config.plugins.push(
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false },
      sourceMap: false
    }),
    new webpack.optimize.ModuleConcatenationPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new CompressionPlugin()
  );
} else {
  config.plugins.push(
    new webpack.HotModuleReplacementPlugin() // Enable HMR
  );
  require('dotenv').config();

  config.devServer = {
    host: process.env.BIND || 'localhost',
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' },
    hot: true
  };
  // Source maps
  config.devtool = 'inline-source-map';
}

module.exports = config;
