import { WrapperFactory, wrapperRegistry } from './wrapperFactory';

jest.unmock('./wrapperFactory');

describe('wrapperRegistry', () => {
  const wrapper = () => {};

  it('should register a wrapper', () => {
    wrapperRegistry.register('wrapper_a', wrapper);
    expect(wrapperRegistry.getWrapper('wrapper_a')).toEqual(wrapper);
  });

  it('should not register a wrapper twice', () => {
    wrapperRegistry.register('wrapper_b', wrapper);
    expect(() => {
      wrapperRegistry.register('wrapper_b', wrapper);
    }).toThrow('Wrapper name already taken: wrapper_b');
  });
});

describe('WrapperFactory', () => {
  it('builds a wrapper', () => {
    wrapperRegistry.register('name_wrapper', name => component =>
      `${name}(${component})`
    );

    const factory = new WrapperFactory();

    factory.with('name_wrapper', 'WrapperA').with('name_wrapper', 'WrapperB');
    expect(factory.wrapper('Component')).toEqual(
      'WrapperB(WrapperA(Component))'
    );
  });
});
