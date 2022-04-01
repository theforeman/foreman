import React from 'react';
import { mount } from '@theforeman/test';
import TimePicker from './TimePicker';

test('TimePicker is working properly', () => {
  const component = mount(<TimePicker value="2/2/2   5:22:31 PM" />);

  expect(component.render()).toMatchSnapshot();
});

test('TimePicker is working properly with time only', () => {
  const component = mount(<TimePicker value="5:22:31 PM  " />);

  expect(component.render()).toMatchSnapshot();
});

test('Edit form of TimePicker', () => {
  const component = mount(<TimePicker value="2:22:31 PM  " />);
  component
    .find('input')
    .simulate('change', { target: { value: '2:42 PM  ' } });
  expect(component.render()).toMatchSnapshot();
  expect(component.state().value).toEqual(new Date('1/1/1 2:42:00 PM  '));
});
