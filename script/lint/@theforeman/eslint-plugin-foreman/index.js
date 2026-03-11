const core = require('./lint_generic_config');

module.exports = {
  configs: {
    core,
    plugins: {
      rules: {
        'import/no-unresolved': [
          'error',
          {
            ignore: ['foremanReact/.*', '^foremanJSTestSetup$'],
          },
        ],
        'import/extensions': [
          'error',
          {
            ignore: ['foremanReact/.*', '^foremanJSTestSetup$'],
          },
        ],
      },
    },
  },
};
