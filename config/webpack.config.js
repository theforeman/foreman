'use strict';

require( 'es6-promise' ).polyfill(); //needed for compatibility with older node versions

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGETNODE_ENV=production on the environment to add asset fingerprints
var production = process.env.RAILS_ENV === 'production' || process.env.NODE_ENV === 'production';

var config = {
  entry: {
    // Sources are expected to live in $app_root/webpack
    'bundle': './webpack/assets/javascripts/bundle.js'
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  resolve: {
    extensions: ['', '.js'],
    root: path.join(__dirname, '..', 'webpack')
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader")
      },
      {
        test: /(\.png|\.gif)$/,
        loader: "url-loader?limit=32767"
      }
    ]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    new ExtractTextPlugin(production ? '[name]-[chunkhash].css' : '[name].css', {
            allChunks: true
    })
  ]
};

if (production) {
  config.plugins.push(
    new webpack.NoErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false },
      sourceMap: false
    }),
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') }
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin()
  );
} else {
  require('dotenv').config();

  config.devServer = {
    host: process.env.BIND || '127.0.0.1',
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  // Source maps
  config.devtool = 'inline-source-map';
}

module.exports = config;
