/* eslint-disable spellcheck/spell-checker */
const fs = require('fs');
const path = require('path');

const nodeModules = path.resolve(__dirname, '..', 'node_modules');
const packageJsonPath = path.resolve(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

const dependencies = {
  ...packageJson.dependencies,
  ...packageJson.devDependencies,
  '@apollo/client/testing': '@apollo/client/testing',
}; // Use shared dependencies from foreman node_modules and not plugin node_modules to avoid jest errors due to multiple instances of same package

const moduleNameMapper = {};
Object.keys(dependencies).forEach(dep => {
  moduleNameMapper[`^${dep}$`] = path.resolve(nodeModules, dep);
});

const foremanReactFull = path.resolve(
  __dirname,
  'assets/javascripts/react_app'
);
const foremanTest = path.resolve(__dirname, 'theforeman_test_dependencies.js');

module.exports = {
  verbose: true,
  logHeapUsage: true,
  maxWorkers: 2,
  collectCoverage: true,
  coverageReporters: ['lcov'],
  coverageDirectory: `../coverage`,
  setupFiles: [require.resolve('jest-prop-type-error')],
  testMatch: [
    '**/__tests__/**/*.test.(js|ts|tsx)',
    '**/?(*.)+(spec|test).(js|ts|tsx)',
  ],
  testPathIgnorePatterns: [
    '/gems/',
    '<rootDir>/.vendor/',
    '/node_modules/',
    '<rootDir>/foreman/',
    '.+fixtures.+',
    'foreman/webpack', // dont test foreman core in plugins
  ],
  moduleDirectories: [`node_modules`, '<rootDir>/node_modules'],
  transform: {
    '^.+\\.js?$': 'babel-jest',
    '\\.(gql|graphql)$': require.resolve('jest-transform-graphql'), // for graphql-tag
  },
  snapshotSerializers: [require.resolve('enzyme-to-json/serializer')],
  moduleNameMapper: {
    '^.+\\.(png|gif|css|scss)$': `${nodeModules}/identity-obj-proxy/src/index.js`,
    ...moduleNameMapper,
    '^@patternfly/react-table/deprecated$': `${nodeModules}/@patternfly/react-table/deprecated`,
    '^dnd-core$': `${nodeModules}/dnd-core/dist/cjs`,
    '^react-dnd$': `${nodeModules}/react-dnd/dist/cjs`,
    '^react-dnd-html5-backend$': `${nodeModules}/react-dnd-html5-backend/dist/cjs`,
    '^react-dnd-touch-backend$': `${nodeModules}/react-dnd-touch-backend/dist/cjs`,
    '^react-dnd-test-backend$': `${nodeModules}/react-dnd-test-backend/dist/cjs`,
    '^react-dnd-test-utils$': `${nodeModules}/react-dnd-test-utils/dist/cjs`,
    '^foremanReact(.*)$': `${foremanReactFull}/$1`,
    '^@theforeman/test$': foremanTest,
    '^react-redux-test-utils$': foremanTest,
    '^victory(.*)$': `${nodeModules}/victory$1`,
  },
  globals: {
    __testing__: true,
    URL_PREFIX: '',
  },
};
