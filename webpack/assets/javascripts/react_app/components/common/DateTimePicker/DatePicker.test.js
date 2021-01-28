import React from 'react';
import { shallow, mount } from '@theforeman/test';
import DatePicker from './DatePicker';

describe('DatePicker', () => {
  test('renders properly', () => {
    const component = shallow(<DatePicker/>);
    expect(component.render()).toMatchSnapshot();
  });

  test('prefils the value from prop', () => {
    const component = shallow(<DatePicker value="2/21/2019 , 2:22:31 PM"/>);
    expect(component.render()).toMatchSnapshot();
  });

  test('edit works', () => {
    const component = mount(<DatePicker value="2/21/2019  " />);
    component
      .find('input')
      .simulate('change', { target: { value: '2/22/2019' } });
    expect(component.state().value).toEqual(new Date('2/22/2019'));
    expect(component.render()).toMatchSnapshot();
  });
});
