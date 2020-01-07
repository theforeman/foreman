import { shallow } from '@theforeman/test';
import React from 'react';
import FactChart from '../FactChart';
import { props } from '../FactChart.fixtures';

describe('factCharts', () => {
  it('should render open', () => {
    const wrapper = shallow(<FactChart {...props} />);
    expect(wrapper).toMatchSnapshot();
  });

  it('should render closed', () => {
    const wrapper = shallow(<FactChart {...props} modalToDisplay={false} />);
    expect(wrapper).toMatchSnapshot();
  });
});
