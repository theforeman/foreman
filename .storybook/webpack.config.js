let path = require('path');

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
        test: /\.css$/,
        loaders: ['style-loader', 'css-loader']
      },
      {
        test: /(\.png|\.gif)$/,
        loader: 'url-loader?limit=32767'
      },
      {
        test: /\.scss$/,
        loaders: ['style-loader', 'css-loader', 'sass-loader']
      }
    ]
  }
};
