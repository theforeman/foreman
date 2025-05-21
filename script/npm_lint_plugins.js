#!/usr/bin/env node
/* eslint-disable no-var */
/* eslint-disable no-console */

var fs = require('fs');

const { spawnSync, execSync } = require('child_process');
const path = require('path');

var { filterPluginDirectories } = require('./plugin_webpack_directories');

var { allPluginDirs, skippedDirsKeys, dirsKeys } = filterPluginDirectories();
var passedArgs = process.argv.slice(2);

function pluginDefinesLint(pluginPath) {
  var packageData = JSON.parse(fs.readFileSync(`${pluginPath}/package.json`));

  return packageData.scripts && packageData.scripts.lint;
}

if (passedArgs[0] && passedArgs[0][0] !== '-') {
  // if the argument is --fix and not a plugin name npm lint:plugins katello --fix
  dirsKeys = dirsKeys.filter(dir => dir.endsWith(passedArgs[0]));
  passedArgs.shift();
}
try {
  const scriptPath = path.join(__dirname, 'lint', 'link-eslint-plugin.js');
  execSync(`node ${scriptPath}`, { stdio: 'inherit' });
} catch (error) {
  console.error(`Error: ${error.message}`);
}

const packageJsonDirectories = [
  './',
  './node_modules/@theforeman/vendor-core/',
];
dirsKeys.forEach(dirsKey => {
  const pluginPath = allPluginDirs[dirsKey];
  const pluginLintScript = pluginDefinesLint(pluginPath);
  if (pluginLintScript?.includes('tfm-lint') || !pluginLintScript?.length) {
    const eslintConfigPath = path.join(
      __dirname,
      'lint/@theforeman/eslint-plugin-foreman',
      '/lint_generic_config.js'
    );

    const rule = `import/no-extraneous-dependencies: ["error", { "packageDir": [${[
      ...packageJsonDirectories,
      pluginPath,
    ]
      .map(item => `"${item}"`)
      .join(',')}]}]`; // Adding the plugins own node_modules to the import search

    spawnSync(
      'npx',
      [
        'eslint',
        '--rule',
        rule,
        path.join(pluginPath, 'webpack'),
        '-c',
        eslintConfigPath,
      ],
      {
        cwd: path.join(__dirname, '..'),
        stdio: 'inherit',
      }
    );
  } else if (pluginLintScript?.length) {
    // Dont run foreman config lint for plugins with custom lint
    spawnSync('npm', ['run', 'lint'], {
      env: process.env,
      cwd: pluginPath,
      stdio: 'inherit',
    });
  }
});

console.log(
  'The following plugin dirs were gems, and therefore skipped: ',
  skippedDirsKeys
);
