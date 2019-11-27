const { plugins } = require('../script/webpacked_plugins');
const tfmBuildConfig = require('./tfm-builder.config');

const tfmDevServerConfig = { ...tfmBuildConfig, plugins };

module.exports = tfmDevServerConfig;
