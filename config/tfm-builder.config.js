const path = require('path');

module.exports = {
  entry: {
    bundle: require.resolve('../webpack/assets/javascripts/bundle.js'),
  },
  output: path.resolve(__dirname, '../public/webpack/'),
};
