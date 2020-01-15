import React from 'react';
import BarChart from './';

export default {
  title: 'Components|Charts/BarChart',
  component: BarChart,
};

export const barChart = () => (
  <BarChart
    data={[
      ['Fedora 21', 3],
      ['Ubuntu 14.04', 4],
      ['Centos 7', 2],
      ['Debian 8', 1],
    ]}
    xAxisLabel="OS"
    yAxisLabel="COUNT"
  />
);
