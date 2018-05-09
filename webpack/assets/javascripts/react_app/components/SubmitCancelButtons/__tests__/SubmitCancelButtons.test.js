import React from 'react';
import { mount } from 'enzyme';

import SubmitCancelButtons from '../SubmitCancelButtons';

describe('SubmitCancelButtons', () => {
  it('triggers', () => {
    const props = {
      data: { cancelPath: '/hosts' },
      onCancel: jest.fn(),
      onSubmit: jest.fn(),
      onMount: jest.fn(),
      replacer: { replace: jest.fn() },
    };
    const component = mount(<SubmitCancelButtons {...props} />);

    expect(props.onMount.mock.calls.length).toBe(1);
    expect(props.onCancel.mock.calls.length).toBe(0);
    expect(props.onSubmit.mock.calls.length).toBe(0);

    component.find('.btn .btn-primary').simulate('click');
    expect(props.onSubmit.mock.calls.length).toBe(1);
    expect(props.onCancel.mock.calls.length).toBe(0);
    expect(props.onMount.mock.calls.length).toBe(1);

    component.find('.btn .btn-default').simulate('click');
    expect(props.onSubmit.mock.calls.length).toBe(1);
    expect(props.onCancel.mock.calls.length).toBe(1);
    expect(props.onMount.mock.calls.length).toBe(1);
  });
});
