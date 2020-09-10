import React from 'react';

import withReactRoutes from './withReactRoutes';

const Component = props => <div>I am component</div>;

describe('withReactRoutes', () => {
  it('should render and pass props', () => {
    expect(withReactRoutes(Component)({ name: 'foo' })).toMatchSnapshot(
      'should render and pass props'
    );
  });
});
