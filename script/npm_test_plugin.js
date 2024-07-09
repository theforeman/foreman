#!/usr/bin/env node
/* eslint-disable import/no-dynamic-require */
/* eslint-disable no-console */
/* eslint-disable no-var */

/* This script is used to run tests for all plugins that have a `lint` script defined in their package.json
  To run tests for an individual plugin, pass the plugin name as the first argument to the script
  For example, to run tests for the `foreman-tasks` plugin, run: `npm run test:plugins foreman-tasks`
  To pass arguments to jest, pass them after the plugin name like so: `npm run test:plugins foreman-tasks -- --debug`
*/

var fs = require('fs');
var path = require('path');
var lodash = require('lodash');
var childProcess = require('child_process');
var { filterPluginDirectories } = require('./plugin_webpack_directories');

var { allPluginDirs, skippedDirsKeys, dirsKeys } = filterPluginDirectories();

const passedArgs = process.argv.slice(2);
const coreConfigPath = path.resolve(__dirname, '../webpack/jest.config.js');
const coreConfig = require(coreConfigPath);
process.env.NODE_OPTIONS =
  process.env.NODE_OPTIONS || '--max-old-space-size=8192';

const runTests = async () => {
  if (passedArgs[0] && passedArgs[0][0] !== '-') {
    // if the argument is --debug and not a plugin name npm run test:plugins katello --debug
    dirsKeys = dirsKeys.filter(dir => dir.endsWith(passedArgs[0]));
    passedArgs.shift();
  }
  function customizer(objValue, srcValue) {
    if (lodash.isArray(objValue)) {
      return lodash.uniq(objValue.concat(srcValue));
    }
    return undefined;
  }
  const errors = [];
  // eslint-disable-next-line no-unused-vars
  for (const dirsKey of dirsKeys) {
    const pluginPath = allPluginDirs[dirsKey];
    const packageHasWebpack = fs.existsSync(`${pluginPath}/webpack`);
    if (packageHasWebpack) {
      const testSetupFiles = [
        path.resolve(__dirname, '../webpack/global_test_setup.js'),
      ];
      const testSetupPath = path.join(pluginPath, 'webpack', 'test_setup.js');
      if (fs.existsSync(testSetupPath)) {
        testSetupFiles.unshift(testSetupPath);
      }
      const pluginConfigPath = path.join(pluginPath, 'jest.config.js');
      const combinedConfigPath = path.join(
        pluginPath,
        'combined.jest.config.js'
      );

      if (fs.existsSync(pluginConfigPath)) {
        // eslint-disable-next-line global-require
        const pluginConfig = require(pluginConfigPath);

        const combinedConfig = lodash.mergeWith(
          pluginConfig,
          {
            ...coreConfig,
            setupFilesAfterEnv: [
              path.resolve(__dirname, '../webpack/global_test_setup.js'),
            ],
          },
          customizer
        );
        combinedConfig.snapshotSerializers = coreConfig.snapshotSerializers;
        fs.writeFileSync(
          combinedConfigPath,
          `module.exports = ${JSON.stringify(combinedConfig, null, 2)};`,
          'utf8'
        );
      }
      const pluginConfigOverride = fs.existsSync(pluginConfigPath);
      const configPath = pluginConfigOverride
        ? combinedConfigPath
        : coreConfigPath;
      const corePath = path.resolve(__dirname, '../', 'webpack');
      const args = [
        'jest',
        '--roots',
        pluginPath,
        corePath,
        `--config=${configPath}`,
        pluginConfigOverride
          ? ''
          : `--setupFilesAfterEnv ${testSetupFiles.join(' ')}`,
        '--color',
        ...passedArgs,
      ];

      // eslint-disable-next-line no-await-in-loop
      try {
        childProcess.execSync(['npx', ...args].join(' '), {
          shell: true,
          stdio: 'inherit',
        });
      } catch (err) {
        errors.push(
          `Run for npm run test:plugins ${path.basename(pluginPath)} failed`
        );
      } finally {
        if (fs.existsSync(combinedConfigPath)) {
          fs.unlinkSync(combinedConfigPath);
        }
      }
    }
  }
  if (errors.length)
    console.error(
      'Errors while running were printed in the output above\n',
      errors.join('\n')
    );
};

runTests();

console.log(
  'The following plugin dirs were gems, and therefore skipped: ',
  skippedDirsKeys
);
