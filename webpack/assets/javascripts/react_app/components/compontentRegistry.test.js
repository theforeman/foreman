import React from 'react';
import componentRegistry from './componentRegistry';

jest.unmock('./componentRegistry');

class FakeComponent extends React.Component {}

describe('Component registry', () => {
  it('should register a component', () => {
    const name = 'TestComponent';

    componentRegistry.register({ name, type: FakeComponent });
    const comp = componentRegistry.getComponent(name);

    expect(comp).toBeTruthy();
    expect(comp.store).toBeTruthy();
    expect(comp.data).toBeTruthy();
  });

  it('should not register a component twice', () => {
    const name = 'TwiceComponent';

    componentRegistry.register({ name, type: FakeComponent });
    expect(() =>
      componentRegistry.register({ name, type: FakeComponent })).toThrow('Component name already taken: TwiceComponent');
  });

  it('should not register a component without a name', () => {
    expect(() =>
      componentRegistry.register({ type: FakeComponent })).toThrow('Component name or type is missing');
  });

  it('should not register a component without a type', () => {
    expect(() =>
      componentRegistry.register({ name: 'SadComponent' })).toThrow('Component name or type is missing');
  });

  it('should register multiple components', () => {
    const first = 'FirstComponent';
    const second = 'SecondComponent';

    componentRegistry.registerMultiple([{ name: first, type: FakeComponent },
      { name: second, type: FakeComponent }]);
    expect(componentRegistry.getComponent(first)).toBeTruthy();
    expect(componentRegistry.getComponent(second)).toBeTruthy();
  });

  it('should return component markup', () => {
    const name = 'MarkupComponent';

    componentRegistry.register({ name, type: FakeComponent, store: false });
    const markup = componentRegistry.markup(name, { fakeData: true }, {});

    expect(markup).toEqual(<FakeComponent data={{ fakeData: true }} store={undefined} />);
  });
});
