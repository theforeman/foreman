const path = require('path');

module.exports = {
  rootDir: path.resolve(__dirname, '../'),
  roots: ['<rootDir>/webpack/', '<rootDir>/script/'],
  automock: true,
  verbose: true,
  testMatch: ['**/*.test.js'],
  testURL: 'http://localhost/',
  collectCoverage: true,
  collectCoverageFrom: [
    'webpack/**/*.js',
    '!webpack/**/bundle*',
    '!webpack/stories/**',
    '!webpack/**/*stories.js',
  ],
  coverageReporters: ['lcov'],
  unmockedModulePathPatterns: ['react', 'node_modules/'],
  moduleNameMapper: {
    '^.+\\.(png|gif|css|scss)$': 'identity-obj-proxy',
    "^dnd-core$": "dnd-core/dist/cjs/index.js",
    "^react-dnd$": "react-dnd/dist/cjs/index.js",
    "^react-dnd-html5-backend$": "react-dnd-html5-backend/dist/cjs/index.js",
    "^react-dnd-test-backend$": "react-dnd-test-backend/dist/cjs/index.js",
    "^react-dnd-test-utils$": "react-dnd-test-utils/dist/cjs/index.js"
  },
  globals: {
    __testing__: true,
    URL_PREFIX: '',
  },
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  moduleDirectories: ['node_modules/@theforeman/vendor-core/node_modules', 'node_modules'],
  setupFiles: [
    'raf/polyfill',
    'jest-prop-type-error',
    '<rootDir>/webpack/test_setup.js',
  ],
};
