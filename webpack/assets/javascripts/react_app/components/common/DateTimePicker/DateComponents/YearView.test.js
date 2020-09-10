import React from 'react';
import { shallow } from '@theforeman/test';
import YearView from './YearView';

test('YearView is working properly', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  const component = shallow(<YearView date={date} />);

  expect(component.render()).toMatchSnapshot();
});

test('Edit month YearView', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  const setSelected = jest.fn();
  const component = shallow(<YearView date={date} setSelected={setSelected} />);
  expect(component.render()).toMatchSnapshot();
  component
    .find('.month')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('1/21/2019 , 2:22:31 PM'));
});

test('Edit year and month YearView', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  const setSelected = jest.fn();
  const component = shallow(<YearView date={date} setSelected={setSelected} />);
  expect(component.render()).toMatchSnapshot();
  component
    .find('.next')
    .first()
    .simulate('click');
  component
    .find('.month')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('1/21/2020 , 2:22:31 PM'));
  component
    .find('.prev')
    .first()
    .simulate('click');
  component
    .find('.month')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('1/21/2019 , 2:22:31 PM'));
});
