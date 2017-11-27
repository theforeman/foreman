const webpack = require('webpack');
const merge = require('webpack-merge');
const environment = require('./environment');
const pluginsConfig = require('./plugins');

/*
 * Apply webpack plugins
 */
environment.plugins.set(
  'NoEmitOnErrors',
  new webpack.NoEmitOnErrorsPlugin(),
);
environment.plugins.set(
  'OccurrenceOrder',
  new webpack.optimize.OccurrenceOrderPlugin(),
);

module.exports = merge(environment.toWebpackConfig(), pluginsConfig);
