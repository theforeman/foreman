import React from 'react';
import { shallow, mount } from '@theforeman/test';
import DecadeView from './DecadeView';

test('DecadeView is working properly', () => {
  const date = new Date('1/1/2020 , 2:22:31 PM');
  const component = shallow(<DecadeView date={date} />);

  expect(component.render()).toMatchSnapshot();
});

test('Edit year DecadeView', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  const setSelected = jest.fn();
  const component = mount(<DecadeView date={date} setSelected={setSelected} />);
  expect(component.render()).toMatchSnapshot();
  component
    .find('.year')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('2/21/2010,   2:22:31 PM'));
});

test('Edit decade DecadeView', () => {
  const date = new Date('2/21/2019 , 2:22:31 PM');
  const setSelected = jest.fn();
  const component = mount(<DecadeView date={date} setSelected={setSelected} />);
  expect(component.render()).toMatchSnapshot();
  component
    .find('.next')
    .first()
    .simulate('click');
  component
    .find('.year')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('2/21/2020 , 2:22:31 PM'));
  component
    .find('.prev')
    .first()
    .simulate('click');
  component
    .find('.year')
    .first()
    .simulate('click');
  expect(setSelected).toBeCalledWith(new Date('2/21/2010 , 2:22:31 PM'));
});
