import React from 'react';
import { shallow } from '@theforeman/test';
import TodayButton from './TodayButton';

const mockedDate = new Date('2/21/2019 , 3:22:31 PM');

global.Date = jest.fn(() => mockedDate);
global.Date.now = jest.fn(() => mockedDate);

test('TodayButton is working properly', () => {
  const component = shallow(<TodayButton />);

  expect(component.render()).toMatchSnapshot();
});
test('TodayButton Click is setting the date', () => {
  const setSelected = jest.fn();
  const component = shallow(<TodayButton setSelected={setSelected} />);
  const date = new Date();
  component.find('.today-button').simulate('click');
  expect(setSelected).toBeCalledWith(date);
});
