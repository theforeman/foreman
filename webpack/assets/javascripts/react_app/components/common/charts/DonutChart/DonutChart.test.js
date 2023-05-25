import { shallow } from '@theforeman/test';
import React from 'react';
import { mockData, emptyData } from './DonutChart.fixtures';
import DonutChart from './';
import * as chartService from '../../../../../services/charts/DonutChartService';

jest.unmock('./');
describe('renders DonutChart', () => {
  it('render donut chart', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    const wrapper = shallow(<DonutChart data={mockData} />);

    expect(wrapper).toMatchSnapshot();
  });
  it('render empty state', () => {
    chartService.getDonutChartConfig = jest.fn(() => emptyData);
    const wrapper = shallow(<DonutChart data={emptyData} />);

    expect(wrapper).toMatchSnapshot();
  });
});
