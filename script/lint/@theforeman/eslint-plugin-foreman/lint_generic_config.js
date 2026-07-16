const packageJsonDirectories = ['./'];
const vendorEntry = require('../../../../config/webpack.vendor');

module.exports = {
  plugins: [
    'patternfly-react',
    'promise',
    'jquery',
    'react-hooks',
    '@theforeman/eslint-plugin-rules',
  ],
  extends: ['plugin:patternfly-react/recommended', 'plugin:jquery/deprecated'],
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    'max-lines': [
      'error',
      {
        max: 300,
        skipBlankLines: true,
        skipComments: true,
      },
    ],
    'no-restricted-syntax': [
      'error',
      {
        selector: 'ForInStatement',
        message:
          'for..in loops iterate over the entire prototype chain, which is virtually never what you want. Use Object.{keys,values,entries}, and iterate over the resulting array.',
      },
      {
        selector: 'LabeledStatement',
        message:
          'Labels are a form of GOTO; using them makes code confusing and hard to maintain and understand.',
      },
      {
        selector: 'WithStatement',
        message:
          '`with` is disallowed in strict mode because it makes code impossible to predict and optimize.',
      },
    ],
    'promise/prefer-await-to-then': 'error',
    'prettier/prettier': [
      'error',
      {
        singleQuote: true,
        trailingComma: 'es5',
      },
    ],
    'import/no-unresolved': [
      'error',
      {
        ignore: ['foremanReact/.*', '^foremanJSTestSetup$', ...vendorEntry],
      },
    ],
    'import/extensions': [
      'error',
      {
        ignore: ['foremanReact/.*', '^foremanJSTestSetup$'],
      },
    ],
    'import/no-extraneous-dependencies': [
      'error',
      {
        packageDir: packageJsonDirectories,
      },
    ],
    'no-magic-numbers': [
      'error',
      {
        ignore: [
          // Common general-purpose values
          0,
          1,
          -1,
          2,
          3,
          4,
          5,
          6,
          8,
          9,
          // Pagination per-page options
          10,
          15,
          20,
          25,
          50,
        ],
        ignoreArrayIndexes: true,
        enforceConst: true,
        detectObjects: false,
      },
    ],
    '@theforeman/rules/require-ouiaid': 'error',
    '@theforeman/rules/prefer-pf-components': 'error',
    '@theforeman/rules/prefer-pf-props': 'error',
  },
};
