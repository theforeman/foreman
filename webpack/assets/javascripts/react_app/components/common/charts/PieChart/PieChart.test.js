// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import React from 'react';
import PieChart from './';
import chartData from './PieChart.fixtures';
import { mount } from 'enzyme';
import c3 from 'c3';
jest.mock('c3');
jest.unmock('../../../../../services/ChartService');
global.patternfly = {
  pfSetDonutChartTitle: jest.fn(),
};

describe('renders pieChart', () => {
  c3.generate = jest.fn().mockReturnValue({ destroy: '' });
  it('render', () => {
    mount(<PieChart data={chartData} />);

    expect(c3.generate).toHaveBeenCalled();
  });
});
