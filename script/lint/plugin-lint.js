/* eslint-disable no-console */
// This script is used to lint the plugin codebase using the generic eslint configuration.
// usage in package.json:
//   "scripts": {
//     "lint": "node ../foreman/script/lint/plugin-lint.js"
//   },
// or in a custom script with @theforeman/find-foreman

const { spawn, execSync } = require('child_process');
const path = require('path');

try {
  const sciptPath = path.join(__dirname, 'link-eslint-plugin.js');
  execSync(`node ${sciptPath}`, { stdio: 'inherit' });
} catch (error) {
  console.error(`Error: ${error.message}`);
}

const eslintConfigPath = path.join(__dirname, '/lint_generic_config.js');
const eslint = spawn('npx', ['eslint', './webpack', '-c', eslintConfigPath], {
  stdio: 'inherit',
});

eslint.on('error', error => {
  console.error(`Error: ${error.message}`);
});

eslint.on('close', code => {
  if (code !== 0) {
    console.error(`ESLint process exited with code ${code}`);
  }
});
