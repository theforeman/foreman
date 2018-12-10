#!/usr/bin/env node

/* eslint-disable no-console, no-await-in-loop */
const childProcess = require('child_process');
const path = require('path');
const fs = require('fs');
const util = require('util');
const _mkdirp = require('mkdirp');

const exec = util.promisify(childProcess.exec);
const readFile = util.promisify(fs.readFile);
const writeFile = util.promisify(fs.writeFile);

const mkdirp = util.promisify(_mkdirp);

const cwd = __dirname;

const getPackagesFromArgs = () => {
  const packages = process.argv.slice(2);

  if (packages.length <= 0) {
    throw new Error('Must supply package name as the first argument');
  }

  return packages.map(pkg => ({
    pkg,
    pkgName: pkg.split('@')[0],
  }));
};

const installPackage = async (pkg, dev = false) => {
  const saveType = dev ? '--save-dev' : '--save';
  const command = `npm install ${saveType} ${pkg}`;

  await exec(command, { cwd });

  console.log(`INSTALLED: ${command}`);
};

const generatePackageFolder = async pkgName => {
  const folderPath = path.join(cwd, pkgName);
  const filePath = path.join(cwd, pkgName, 'index.js');

  const fileContent = `// @theforeman/vendor/${pkgName}
export default from '${pkgName}';
export * from '${pkgName}';
`;

  await mkdirp(folderPath);

  await writeFile(filePath, fileContent, {
    encoding: 'utf8',
    overwrite: false,
  });

  console.log(`CREATED: ${filePath}`);
};

const addNewPackageToIndexJs = async pkgName => {
  const indexJsPath = path.join(cwd, 'index.js');

  const indexJsContent = await readFile(indexJsPath, 'utf8');

  const newFileContent = `${indexJsContent}import './${pkgName}';\n`;

  await writeFile(indexJsPath, newFileContent, {
    encoding: 'utf8',
    overwrite: false,
  });

  console.log(`UPDATED: ${indexJsPath}`);
};

const createMigration = async pkgName => {
  const migrationsFile = path.join(cwd, 'migrations.js');

  const migrationsFileContent = await readFile(migrationsFile, 'utf8');
  const newMigration = `  {
    originalStringOrRegex: "from '${pkgName}'",
    replacementString: "from '@theforeman/vendor/${pkgName}'",
  },`;

  const migrationFileLines = migrationsFileContent.split('\n');
  migrationFileLines.splice(-2, 0, ...newMigration.split('\n'));

  const newMigrationsFileContent = migrationFileLines.join('\n');

  await writeFile(migrationsFile, newMigrationsFileContent, {
    encoding: 'utf8',
    overwrite: true,
  });

  console.log(`UPDATED: ${migrationsFile}`);
};

const addJestSetup = async pkgName => {
  const testSetupPath = path.join(cwd, 'jest-setup.js');

  const jestSetupJsContent = await readFile(testSetupPath, 'utf8');

  const newSetupContent = `jest.unmock('@theforeman/vendor/${pkgName}');`;
  const newFileContent = `${jestSetupJsContent}${newSetupContent}\n`;

  await writeFile(testSetupPath, newFileContent, {
    encoding: 'utf8',
    overwrite: false,
  });

  console.log(`UPDATED: ${testSetupPath}`);
};

const run = async () => {
  try {
    const packages = getPackagesFromArgs();

    for (const { pkg, pkgName } of packages) {
      await installPackage(pkg);
      await generatePackageFolder(pkgName);
      await createMigration(pkgName);
      await addJestSetup(pkgName);
      await addNewPackageToIndexJs(pkgName);
    }
  } catch (error) {
    console.error(error);
    process.exit(-1);
  }
};

run();
