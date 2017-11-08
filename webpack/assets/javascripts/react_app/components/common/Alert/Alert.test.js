// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, shallow } from 'enzyme';
import React from 'react';

import Alert from './';

configure({ adapter: new Adapter() });

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
