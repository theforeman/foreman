import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import Form from './Form';

describe('Form', () => {
  it('should render a form', () => {
    const wrapper = shallow(<Form />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should display one base error', () => {
    const wrapper = shallow(<Form error={['invalid something']} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should display multiple base errors', () => {
    const wrapper = shallow(<Form error={['invalid something', 'error too']} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should accept base error title', () => {
    const wrapper = shallow(<Form error={['invalid something']} errorTitle="Oops" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should accept a submit function', () => {
    const submit = jest.fn();
    const wrapper = shallow(<Form onSubmit={submit} />);

    wrapper.find('form').simulate('submit');
    expect(submit).toBeCalled();
  });
});
