import { shallow } from '@theforeman/test';
import React from 'react';
import { FieldLevelHelp } from 'patternfly-react';

import CommonForm from './CommonForm';

describe('common Form', () => {
  it('should display a label field', () => {
    const wrapper = shallow(<CommonForm label="my label" />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should accept a required field', () => {
    const wrapper = shallow(<CommonForm label="my label" required />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should display validation errors if touched', () => {
    const wrapper = shallow(
      <CommonForm label="my label" touched error="is required!" />
    );

    expect(wrapper).toMatchSnapshot();
  });
  it('should not display validation errors if not touched', () => {
    const wrapper = shallow(
      <CommonForm label="my label" error="is required!" />
    );

    expect(wrapper).toMatchSnapshot();
  });
  it('should not display validation errors if there are none', () => {
    const wrapper = shallow(<CommonForm label="my label" />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should accept customized input class', () => {
    const wrapper = shallow(
      <CommonForm name="name" inputClassName="col-md-10" label="Name" />
    );

    expect(wrapper.find('.col-md-10').exists()).toBe(true);
  });

  it('should render tooltip help', () => {
    const wrapper = shallow(
      <CommonForm
        name="name"
        label="Required form field"
        required
        tooltipHelp={<FieldLevelHelp content="This is a helpful tooltip" />}
      />
    );

    expect(wrapper).toMatchSnapshot();
  });
});
