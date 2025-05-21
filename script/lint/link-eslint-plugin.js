/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

function linkEslintPlugin(runPath = process.cwd()) {
  const sourceDirCustom = path.join(
    __dirname,
    '@theforeman',
    'eslint-plugin-rules'
  );
  const destinationDirCustom = path.join(
    runPath,
    'node_modules',
    '@theforeman',
    'eslint-plugin-rules'
  );
  const sourceDirForeman = path.join(
    __dirname,
    '@theforeman',
    'eslint-plugin-foreman'
  );
  const destinationDirForeman = path.join(
    runPath,
    'node_modules',
    '@theforeman',
    'eslint-plugin-foreman'
  );
  function linkAll(src, dst) {
    // instead of creating an npm package for the custom eslint plugin, we symlink it
    // eslint will only search for plugins in node_modules, so we need to symlink it there

    function createSymlink() {
      fs.symlink(src, dst, 'dir', err => {
        if (err) {
          console.error('Error creating symlink:', err);
        }
      });
    }

    // Check if the symlink exists and remove it if it does
    fs.lstat(dst, (err, stats) => {
      if (!err && stats.isSymbolicLink()) {
        fs.unlink(dst, unlinkErr => {
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
  linkAll(sourceDirCustom, destinationDirCustom);
  linkAll(sourceDirForeman, destinationDirForeman);
}
linkEslintPlugin();
