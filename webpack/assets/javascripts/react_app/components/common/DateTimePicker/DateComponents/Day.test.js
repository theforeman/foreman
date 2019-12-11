import React from 'react';
import { shallow } from '@theforeman/test';
import Day from './Day';

test('Day is working properly', () => {
  const day = new Date('2019-01-04 14:22:31');
  const currDate = new Date('2019-01-02 12:22:31');
  const selectedDate = new Date('2019-01-05 18:22:31');
  const component = shallow(
    <Day
      day={day}
      currDate={currDate}
      selectedDate={selectedDate}
      classNamesArray={{ weekend: true }}
    />
  );

  expect(component.render()).toMatchSnapshot();
});
