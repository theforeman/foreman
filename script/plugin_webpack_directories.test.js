import path from 'path';
import pluginUtils from './plugin_webpack_directories';

jest.unmock('./plugin_webpack_directories');

const json = {
  entries: {
    foo: '/some/path/webpack/index.js',
    bar: '/path/to/webpack/index.js',
  },
  paths: ['/some/path/webpack/index.js', '/path/to/webpack/index.js'],
};

describe('sanitizeWebpackDirs', () => {
  it('should return json when debug output is present', () => {
    const output = [
      'Warning: this is not a json',
      'This is some random text',
      JSON.stringify(json),
      '',
    ].join('\n');

    const res = pluginUtils.sanitizeWebpackDirs(output);

    expect(res).toEqual(JSON.stringify(json));
  });

  it('should return json when only json is present', () => {
    const res = pluginUtils.sanitizeWebpackDirs(JSON.stringify(json));

    expect(res).toEqual(JSON.stringify(json));
  });
});

describe('aliasPlugins', () => {
  it('should return aliases for plugins', () => {
    const res = pluginUtils.aliasPlugins(json.entries);

    expect(res).toEqual({ foo: '/some/path/webpack', bar: '/path/to/webpack' });
  });
});

describe('pluginPath', () => {
  it('should return path if exists', () => {
    const obj = { paths: [__filename, '/path/to/webpack/index.js'] };

    const res = pluginUtils.pluginPath(path.basename(__filename))(obj);

    expect(res).toEqual([__filename]);
  });
});
