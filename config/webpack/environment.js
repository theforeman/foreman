const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

/*
 * Apply webpack plugins
 */
environment.plugins.set(
  'CommonsChunkVendor',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    // make sure vendor chunks are node_modules
    minChunks: ({ context }) =>
      context && context.indexOf('node_modules') !== -1,
  }),
);
environment.plugins.set(
  'CommonsChunkManifest',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'manifest',
    minChunks: Infinity,
  }),
);

module.exports = environment;
