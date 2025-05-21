const lintCoreConfig = require('./script/lint/lint_core_config.js');
const lintGenericConfig = require('./script/lint/@theforeman/eslint-plugin-foreman/lint_generic_config.js');

const combinedConfig = {
  ...lintCoreConfig,
  ...lintGenericConfig,
  rules: {
    ...lintCoreConfig.rules,
    ...lintGenericConfig.rules,
  },
  plugins: [
    ...(lintCoreConfig.plugins || []),
    ...(lintGenericConfig.plugins || []),
  ],
  extends: [
    ...(lintCoreConfig.extends || []),
    ...(lintGenericConfig.extends || []),
  ],
};

module.exports = combinedConfig;
