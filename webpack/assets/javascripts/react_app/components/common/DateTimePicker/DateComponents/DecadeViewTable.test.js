import React from 'react';
import { shallow } from '@theforeman/test';
import { DecadeViewTable } from './DecadeViewTable';

test('DecadeViewTable is working properly', () => {
  const component = shallow(
    <DecadeViewTable
      selectedYear={2019}
      yearArray={[
        2010,
        2011,
        2012,
        2013,
        2014,
        2015,
        2016,
        2017,
        2018,
        2019,
        2020,
        2021,
      ]}
    />
  );

  expect(component.render()).toMatchSnapshot();
});
