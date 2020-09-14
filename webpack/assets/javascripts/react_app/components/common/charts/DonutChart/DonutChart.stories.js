import React from 'react';
import DonutChart from './';

export default {
  title: 'Components/Charts/DonutChart',
  component: DonutChart,
};

export const donutChart = () => (
  <DonutChart
    data={[
      ['Out of sync hosts', 1],
      ['Hosts with no reports', 1000],
    ]}
  />
);
