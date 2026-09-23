const presets = [
  [require.resolve('@babel/preset-env'), { modules: 'commonjs' }],
  require.resolve('@babel/preset-react'),
];

module.exports = presets;
