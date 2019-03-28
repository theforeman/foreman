import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import Header from './Header';

test('Header is working properly', () => {
  const date = new Date('2019-01-04 14:22:31');
  const component = shallow(<Header date={date} />);

  expect(toJson(component.render())).toMatchSnapshot();
});

test('Header is working properly with different week start', () => {
  const date = new Date('2019-01-04 14:22:31');
  const component = shallow(<Header date={date} weekStartsOn={5} />);

  expect(toJson(component.render())).toMatchSnapshot();
});
