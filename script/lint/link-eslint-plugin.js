/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

function linkEslintPlugin(runPath = process.cwd()) {
  // instead of creating an npm package for the custom eslint plugin, we symlink it
  // eslint will only search for plugins in node_modules, so we need to symlink it there
  const sourceDir = path.join(__dirname, '@foreman');
  const destinationDir = path.join(runPath, 'node_modules', '@foreman');
  function createSymlink() {
    fs.symlink(sourceDir, destinationDir, 'dir', err => {
      if (err) {
        console.error('Error creating symlink:', err);
      }
    });
  }

  // Check if the symlink exists and remove it if it does
  fs.lstat(destinationDir, (err, stats) => {
    if (!err && stats.isSymbolicLink()) {
      fs.unlink(destinationDir, unlinkErr => {
        if (unlinkErr) {
          console.error('Error removing existing symlink:', unlinkErr);
          return;
        }
        createSymlink();
      });
    } else {
      createSymlink();
    }
  });
}
linkEslintPlugin();
