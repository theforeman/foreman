const md5 = require('md5');

class BreakingChangeModuleIdentifier {
  constructor(options) {
    this.options = options || {};
  }

  // eslint-disable-next-line class-methods-use-this
  apply(compiler) {
    compiler.plugin('normal-module-factory', normalModuleFactory => {
      normalModuleFactory.plugin('after-resolve', (data, callback) => {
        const metadata = data.resourceResolveData.descriptionFileData;
        normalModuleFactory.plugin('create-module', result => {
          result.rawRequest = metadata;
        });
        callback(null, data);
      });
    });

    compiler.plugin('compilation', compilation => {
      compilation.plugin('before-module-ids', modules => {
        modules.forEach(module => {
          if (module.rawRequest && module.portableId) {
            const { rawRequest, portableId } = module;
            const moduleData = createModuleData(rawRequest, portableId);
            module.id = md5(moduleData);
          }
        });
      });
    });
  }
}

const createModuleData = (rawRequest, portableId) => {
  let moduleData = '';
  const { name, author, version } = rawRequest;

  if (name) {
    moduleData += name;
    // use the portable id to make modules within the same package unique
    // split after the package name to make it not dependent on path
    moduleData += portableId
      .split(name)
      .slice(1)
      .join('');
  }

  if (author) {
    if (typeof author === 'string') {
      moduleData += author;
    } else if (author.name) {
      moduleData += author.name;
    }
  }

  const [x, y] = version.split('.');
  if (x) moduleData += x;
  if (y) moduleData += y;

  return moduleData;
};

module.exports = BreakingChangeModuleIdentifier;
