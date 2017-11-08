// Configure Enzyme
import c3 from 'c3';
import Adapter from 'enzyme-adapter-react-16';
import { configure, mount } from 'enzyme';
import React from 'react';

import chartData from './PieChart.fixtures';
import PieChart from './';

configure({ adapter: new Adapter() });

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
