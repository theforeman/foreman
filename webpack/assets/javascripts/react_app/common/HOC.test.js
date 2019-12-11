import React from 'react';
import { mount } from '@theforeman/test';

import { callOnMount, withRenderHandler, callOnPopState } from './HOC';

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

  it('test callOnPopState', () => {
    const callback = jest.fn();
    const props = {
      history: { action: 'PUSH' },
      location: { search: 'search' },
    };

    const OnPopState = callOnPopState(callback)(Component);
    const wrapper = mount(<OnPopState {...props} />);
    wrapper.setProps({
      history: { action: 'POP' },
      location: { search: 'changed' },
    });
    expect(callback).toHaveBeenCalled();
  });
});
