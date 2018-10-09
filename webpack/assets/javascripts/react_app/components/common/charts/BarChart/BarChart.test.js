import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import React from 'react';
import BarChart from './';
import * as chartService from '../../../../../services/charts/BarChartService';
import {
  barChartConfig,
  barChartData,
  emptyData,
  barChartConfigWithEmptyData,
} from './BarChart.fixtures';

jest.unmock('./');
describe('renders BarChart', () => {
  it('render bar chart', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfig);
    const wrapper = shallow(<BarChart data={barChartData.data} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('render empty state', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfigWithEmptyData);
    const wrapper = shallow(<BarChart data={emptyData} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
