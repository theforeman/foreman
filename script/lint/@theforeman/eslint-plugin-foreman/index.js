const core = require('./lint_generic_config');

module.exports = {
  configs: {
    core,
    plugins: {
      rules: {
        'import/no-unresolved': [
          'error',
          {
            ignore: ['foremanReact/.*'],
          },
        ],
        'import/extensions': [
          'error',
          {
            ignore: ['foremanReact/.*'],
          },
        ],
      },
    },
  },
};
