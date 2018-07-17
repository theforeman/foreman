let path = require('path');

// Use storybook's default configuration with our customizations
module.exports = (baseConfig, env, defaultConfig) => {

  // overwrite storybook's default import rules
  defaultConfig.module.rules = [
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
      test: /(\.png|\.gif)$/,
      loader: 'url-loader?limit=32767'
    },
    {
      test: /\.css$/,
      loaders: ['style-loader', 'css-loader']
    },
    {
      test: /\.scss$/,
      loaders: ['style-loader', 'css-loader', 'sass-loader']
    },
    {
      test: /\.md$/,
      loaders: ['raw-loader']
    }
  ]

  return defaultConfig;
};
