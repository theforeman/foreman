require('dotenv').config();

const merge = require('webpack-merge');
const environment = require('./environment');
const pluginsConfig = require('./plugins');

module.exports = merge(environment.toWebpackConfig(), pluginsConfig);
