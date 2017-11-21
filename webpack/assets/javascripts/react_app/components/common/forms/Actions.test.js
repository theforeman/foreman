import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import Actions from './Actions';

describe('actions', () => {
  it('should include a cancel / submit buttons', () => {
    const wrapper = shallow(<Actions />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('buttons could be disabled', () => {
    const wrapper = shallow(<Actions disabled />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should show a spinner when submitting', () => {
    const wrapper = shallow(<Actions submitting />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
