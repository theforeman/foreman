#!/usr/bin/env node
/* eslint-disable no-var */
/* eslint-disable no-console */

var path = require('path');
var { spawnSync } = require('child_process');
var { filterPluginDirectories } = require('./plugin_webpack_directories');

var { allPluginDirs, skippedDirsKeys, dirsKeys } = filterPluginDirectories();
var passedArgs = process.argv.slice(2);
var foremanRoot = path.join(__dirname, '..');
// eslint-disable-next-line spellcheck/spell-checker
var configPath = path.join(foremanRoot, '.stylelintrc.json');
var errors = [];
var pluginPath;
var styleGlob;
var exitCode;

if (passedArgs[0] && passedArgs[0][0] !== '-') {
  dirsKeys = dirsKeys.filter(dir => dir.endsWith(passedArgs[0]));
  passedArgs.shift();
}

dirsKeys.forEach(dirsKey => {
  pluginPath = allPluginDirs[dirsKey];
  styleGlob = path.join(pluginPath, 'webpack/**/*.{scss,css}');

  // eslint-disable-next-line spellcheck/spell-checker
  console.log(`\nRunning stylelint on ${path.basename(pluginPath)}...`);

  exitCode = spawnSync(
    'npx',
    ['stylelint', styleGlob, '--config', configPath, ...passedArgs], // eslint-disable-line spellcheck/spell-checker
    {
      cwd: foremanRoot,
      stdio: 'inherit',
    }
  ).status;

  if (exitCode !== 0) {
    errors.push(`stylelint:plugins ${path.basename(pluginPath)} failed`); // eslint-disable-line spellcheck/spell-checker
  }
});

console.log(
  '\nThe following plugin dirs were gems, and therefore skipped: ',
  skippedDirsKeys
);

if (errors.length) {
  throw new Error(
    ['Errors while running were printed in the output above', ...errors].join(
      '\n'
    )
  );
}
