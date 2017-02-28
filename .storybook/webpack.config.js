var ExtractTextPlugin = require('extract-text-webpack-plugin');
module.exports = {
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      },
      {
        test: /\.css$/,
        loader: 'style-loader!css-loader'
      },
      {
        test: /(\.png|\.gif)$/,
        loader: 'url-loader?limit=32767'
      },
      {
        test: /\.scss$/,
        loader: 'style-loader!css-loader?sourceMap!sass-loader?sourceMap'
      }
    ]
  }
};
