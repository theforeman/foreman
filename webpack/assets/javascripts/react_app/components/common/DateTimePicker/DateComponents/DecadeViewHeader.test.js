import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { DecadeViewHeader } from './DecadeViewHeader';

test('DecadeViewHeader is working properly', () => {
  const component = shallow(<DecadeViewHeader currDecade={2010} />);

  expect(toJson(component.render())).toMatchSnapshot();
});
