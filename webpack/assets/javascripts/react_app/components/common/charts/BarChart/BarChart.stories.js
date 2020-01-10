import React from 'react';
import BarChart from './';
import { barChartData } from './BarChart.fixtures';
import Story from '../../../../../../../stories/components/Story';

export default {
  title: 'Components|Charts|BarChart',
};

export const barChart = () => (
  <Story>
    <BarChart {...barChartData} />
  </Story>
);
