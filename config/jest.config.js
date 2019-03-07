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
  },
  globals: {
    __testing__: true,
    URL_PREFIX: '/',
  },
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  moduleDirectories: ['node_modules'],
  setupFiles: [
    'raf/polyfill',
    'jest-prop-type-error',
    '<rootDir>/webpack/test_setup.js',
  ],
};
