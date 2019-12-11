import { shallow } from '@theforeman/test';
import React from 'react';
import ConfigReports from './ConfigReports';

const mockData = {
  metricsChartData: [['runtime', 5]],
  statusChartData: [['applied', 2]],
  metricsData: { tableData: [['config_retrieval', 10]], total: 10 },
};

describe('ComponentWrapper', () => {
  it('should render config reports', () => {
    const wrapper = shallow(<ConfigReports data={mockData} />);

    expect(wrapper).toMatchSnapshot();
  });
});
