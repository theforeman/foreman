import React from 'react';
import { mount } from 'enzyme';

import { callOnMount, withRenderHandler } from './HOC';

const Component = () => <div>component mounted</div>;

const conditions = {
  isLoading: false,
  hasData: false,
  hasError: false,
  message: {
    type: 'empty',
    text: 'empty',
  },
};

const fixtures = {
  loading: {
    ...conditions,
    isLoading: true,
  },
  component: {
    ...conditions,
    hasData: true,
  },
  empty: {
    ...conditions,
  },
  error: {
    ...conditions,
    hasError: true,
  },
};

const isComponent = withRenderHandler({ Component })(fixtures.component);
const isLoadingComponent = withRenderHandler({ Component })(fixtures.loading);
const isErrorComponent = withRenderHandler({ Component })(fixtures.error);
const isEmptyComponent = withRenderHandler({ Component })(fixtures.empty);

describe('HOCs', () => {
  it('test withRenderHandler', () => {
    expect(isComponent).toMatchSnapshot('should return component');
    expect(isLoadingComponent).toMatchSnapshot('should return loading');
    expect(isErrorComponent).toMatchSnapshot('should return error');
    expect(isEmptyComponent).toMatchSnapshot('should return empty');
  });

  it('test callOnMount', () => {
    const callback = jest.fn();
    const OnMount = callOnMount(callback)(Component);
    mount(<OnMount />);
    expect(callback).toHaveBeenCalled();
  });
});
