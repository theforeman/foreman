import React from 'react';
import componentRegistry from './componentRegistry';

jest.unmock('./componentRegistry');

const FakeComponent = () => '';

describe('Component registry', () => {
  it('should register a component', () => {
    const name = 'TestComponent';

    componentRegistry.register({ name, type: FakeComponent });
    const comp = componentRegistry.getComponent(name);

    expect(comp).toBeTruthy();
    expect(comp.store).toBeTruthy();
    expect(comp.data).toBeTruthy();
  });

  it('should not error when register same component twice', () => {
    const name = 'TwiceComponent';

    componentRegistry.register({ name, type: FakeComponent });
    componentRegistry.register({ name, type: FakeComponent });
    expect(componentRegistry.getComponent(name)).toBeTruthy();
  });

  it('should not register a component without a name', () => {
    expect(() => componentRegistry.register({ type: FakeComponent })).toThrow(
      'Component name or type is missing'
    );
  });

  it('should not register a component without a type', () => {
    expect(() => componentRegistry.register({ name: 'SadComponent' })).toThrow(
      'Component name or type is missing'
    );
  });

  it('should register multiple components', () => {
    const first = 'FirstComponent';
    const second = 'SecondComponent';

    componentRegistry.registerMultiple([
      { name: first, type: FakeComponent },
      { name: second, type: FakeComponent },
    ]);
    expect(componentRegistry.getComponent(first)).toBeTruthy();
    expect(componentRegistry.getComponent(second)).toBeTruthy();
  });

  describe('markup', () => {
    it('should return component markup', () => {
      const name = 'MarkupComponent';

      componentRegistry.register({
        name,
        type: FakeComponent,
        store: true,
        data: true,
      });
      const markup = componentRegistry.markup(name, {
        data: { fakeData: true },
        store: {},
        wrapper(component) {
          return component;
        },
      });

      expect(markup).toEqual(<FakeComponent />);
    });

    it('should use default wrapper', () => {
      const name = 'WrappedMarkupComponent';

      componentRegistry.register({
        name,
        type: FakeComponent,
        store: true,
        data: true,
      });
      componentRegistry.defaultWrapper = jest.fn(
        (component, data, store) => cmp => cmp
      );

      componentRegistry.markup(name, {
        data: 'DATA',
        store: 'STORE',
      });

      expect(componentRegistry.defaultWrapper).toBeCalledWith(
        componentRegistry.getComponent(name),
        'DATA',
        'STORE',
        false
      );
    });
  });
});
