const { modules } = require('@theforeman/vendor-core');

const isRequestedByVendorCore = currentFileDirectory =>
  (currentFileDirectory.includes('foreman-js/packages/vendor-core') ||
    currentFileDirectory.includes('@theforeman/vendor-core')) &&
  !currentFileDirectory.includes(
    'foreman-js/packages/vendor-core/node_modules'
  ) &&
  !currentFileDirectory.includes('@theforeman/vendor-core/node_modules');

const getModuleToResolve = ({ sourcePath, currentFileDirectory }) => {
  // map the custom foreman js module to the correct path
  const requestPath = sourcePath === '.' ? './index' : sourcePath;
  const sourcePathSplit = sourcePath.split('/');
  const name = sourcePathSplit[sourcePathSplit.length - 1];
  const vendorModule = modules.find(m => m.name === name);
  const requestedByVendorCore = isRequestedByVendorCore(currentFileDirectory);

  const shouldResolveCustomVendorModule = modules.find(
    m => m.name === name && m.hasCustomPath && !requestedByVendorCore
  );

  return shouldResolveCustomVendorModule ? vendorModule.path : requestPath;
};

/**
 * resolve a import/require of a node module
 * this method should be calld by the jest-resolver
 * to resolve every require statement
 * This cannot be done with changing the paths with moduleNameMapper
 */

const resolveNodeModule = (sourcePath, currentFile) => {
  const { basedir, rootDir } = currentFile;
  const moduleToResolve = getModuleToResolve({
    sourcePath,
    currentFileDirectory: basedir,
  });
  if (sourcePath.includes('theforeman_test_dependencies')) {
    console.warn(
      'import from @theforeman/test is deprecated, please remove the package and import from enzyme, axios-mock-adapter, foremanReact/testHelpers, foremanReact/common/IntegrationTestHelper directly instead.'
    );
  }
  let results;
  try {
    results = require.resolve(moduleToResolve, {
      paths: [basedir],
    });
  } catch (error) {
    results = currentFile.defaultResolver(moduleToResolve, currentFile);
  }

  return rootDir
    ? results.replace(
        /.*\/foreman-js\/packages/,
        `${rootDir}/node_modules/@theforeman`
      )
    : results;
};

module.exports = resolveNodeModule;
