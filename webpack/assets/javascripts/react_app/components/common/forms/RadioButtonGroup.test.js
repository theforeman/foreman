import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import RadioButtonGroup from './RadioButtonGroup';

describe('radio button group', () => {
  const radios = [
    {
      label: 'A',
      checked: true,
      value: 'A',
    },
    {
      label: 'B',
      checked: false,
      value: 'B',
    },
  ];

  it('should render group of radio buttons', () => {
    const wrapper = shallow(<RadioButtonGroup
        name="RadioButtonGroupTest"
        controlLabel="RadioButtonGroupLabel"
        radios={radios}
      />);
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
