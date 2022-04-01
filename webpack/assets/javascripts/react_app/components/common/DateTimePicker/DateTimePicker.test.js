import React from 'react';
import { mount } from '@theforeman/test';
import DateTimePicker from './DateTimePicker';

describe('DateTimePicker', () => {
  test('renders properly', () => {
    const component = mount(<DateTimePicker/>);
    expect(component.render()).toMatchSnapshot();
  });

  test('prefils the value from prop', () => {
    const component = mount(<DateTimePicker value="2/21/2019 , 2:22:31 PM"/>);
    expect(component.render()).toMatchSnapshot();
  });

  test('edit works', () => {
    const component = mount(<DateTimePicker value="2/21/2019 ,2:22:31 PM" />);
    component
      .find('input')
      .simulate('change', { target: { value: '2/22/2019 , 2:22:31 PM' } });
    expect(component.state().value).toEqual(new Date('2/22/2019 , 2:22:31 PM'));
    expect(component.render()).toMatchSnapshot();
  });
});
