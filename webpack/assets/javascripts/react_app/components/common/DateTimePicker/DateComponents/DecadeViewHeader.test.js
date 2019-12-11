import React from 'react';
import { shallow } from '@theforeman/test';
import { DecadeViewHeader } from './DecadeViewHeader';

test('DecadeViewHeader is working properly', () => {
  const component = shallow(<DecadeViewHeader currDecade={2010} />);

  expect(component.render()).toMatchSnapshot();
});
