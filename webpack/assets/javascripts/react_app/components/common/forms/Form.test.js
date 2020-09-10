import { shallow } from '@theforeman/test';
import React from 'react';

import Form from './Form';

describe('Form', () => {
  it('should render a form', () => {
    const wrapper = shallow(<Form />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should display one base error', () => {
    const wrapper = shallow(
      <Form error={{ errorMsgs: ['invalid something'], severity: 'danger' }} />
    );

    expect(wrapper).toMatchSnapshot();
  });
  it('should display multiple base errors', () => {
    const wrapper = shallow(
      <Form
        error={{
          errorMsgs: ['invalid something', 'error too'],
          severity: 'danger',
        }}
      />
    );

    expect(wrapper).toMatchSnapshot();
  });
  it('should accept base error title', () => {
    const wrapper = shallow(
      <Form
        error={{
          errorMsgs: ['invalid something'],
          severity: 'danger',
        }}
        errorTitle="Oops"
      />
    );

    expect(wrapper).toMatchSnapshot();
  });
  it('should dispaly form errors as warning', () => {
    const wrapper = shallow(
      <Form
        error={{
          errorMsgs: ['Do not feed the trolls'],
          severity: 'warning',
        }}
      />
    );

    expect(wrapper).toMatchSnapshot();
  });
});
