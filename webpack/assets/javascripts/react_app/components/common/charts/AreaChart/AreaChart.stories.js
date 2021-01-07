import React from 'react';
import AreaChart from './';
import { areaChartData } from './AreaChart.fixtures'

export default {
  title: 'Components/Charts/AreaChart',
  component: AreaChart,
};

export const areaChart = () => (
  <AreaChart {...areaChartData} />
);
