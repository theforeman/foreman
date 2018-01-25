const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: [
            path.join(__dirname, '..', 'node_modules/babel-preset-react'),
            path.join(__dirname, '..', 'node_modules/babel-preset-env')
          ],
          plugins: [
            path.join(__dirname, '..', 'node_modules/babel-plugin-transform-class-properties'),
            path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-rest-spread'),
            path.join(__dirname, '..', 'node_modules/babel-plugin-transform-object-assign')
          ]
        }
      },
      {
        test: /(\.png|\.gif|\.jpg|\.svg|\.eot|\.woff|\.woff2|\.ttf)$/,
        loader: 'url-loader',
        options: { limit: 32767 },
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: 'css-loader'
        })
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader', // The backup style loader
          use: [{
            loader: 'css-loader',
            options: { sourceMap: true },
          }, {
            // solve the relative image urls inside jquery-ui
            loader: 'resolve-url-loader',
          }, {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              includePaths: [
                // allow scss files to import variables and mixins without full relative path
                path.join(__dirname, '..', 'webpack/assets/stylesheets/application'),
                // allow patternfly to import bootstrap and fontawesome
                path.join(__dirname, '..', 'node_modules/patternfly/node_modules/bootstrap-sass/assets/stylesheets'),
                path.join(__dirname, '..', 'node_modules/patternfly/node_modules/font-awesome-sass/assets/stylesheets'),
              ],
            },
          }]
        })
      }
    ]
  },

  plugins: [
    new ExtractTextPlugin({
      filename: '[name].css',
      allChunks: true
    }),
  ]
};
