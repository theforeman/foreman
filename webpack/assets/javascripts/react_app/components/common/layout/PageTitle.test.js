import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import PageTitle from './PageTitle';

describe('PageTitle', () => {
  it('should render a page title', () => {
    const wrapper = shallow(<PageTitle text="Penguins"/>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
