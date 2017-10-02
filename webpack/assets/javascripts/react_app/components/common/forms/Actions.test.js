// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });
import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';

import React from 'react';
import Actions from './Actions';

describe('actions', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('should include a cancel / submit buttons', () => {
    const wrapper = shallow(<Actions />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('buttons could be disabled', () => {
    const wrapper = shallow(<Actions disabled={true} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should show a spinner when submitting', () => {
    const wrapper = shallow(<Actions submitting={true} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
