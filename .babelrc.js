const path = require('path');
const babelPresets = path.resolve(__dirname, 'webpack','babel', 'presets.js');
console.log('babelPresets', babelPresets);

module.exports = {
  presets: require(babelPresets),
};
