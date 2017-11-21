import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import Alert from './';

describe('alerts', () => {
  it('can include a title', () => {
    const wrapper = shallow(<Alert title="hello" type="success" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('can accept childrens', () => {
    const wrapper = shallow(<Alert type="success">
      <span id="child">a Child</span>
    </Alert>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
