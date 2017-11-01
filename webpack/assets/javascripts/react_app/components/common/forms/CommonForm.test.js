// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });
import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';

import React from 'react';
import CommonForm from './CommonForm';

describe('common Form', () => {
  beforeEach(() => {
    global.__ = str => str;
  });
  it('should display a label field', () => {
    const wrapper = shallow(<CommonForm label="my label" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should accept a required field', () => {
    const wrapper = shallow(<CommonForm label="my label" required={true} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should display validation errors if touched', () => {
    const wrapper = shallow(
      <CommonForm label="my label" touched={true} error="is required!" />
    );

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should not display validation errors if not touched', () => {
    const wrapper = shallow(
      <CommonForm label="my label" error="is required!" />
    );

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should not display validation errors if there are none', () => {
    const wrapper = shallow(<CommonForm label="my label" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
