import React from 'react';

import LineChart from './index';

export default {
  title: 'Components|Charts/LineChart',
  component: LineChart,
};

export const lineChart = () => (
  <LineChart
    data={[
      ['red', [5, 7, 9], '#AA4643'],
      ['green', [2, 4, 6], '#89A54E'],
    ]}
  />
);

export const lineChartTimeseries = () => (
  <LineChart
    data={[
      ['red', [5, 7, 9], '#AA4643'],
      ['green', [2, 4, 6], '#89A54E'],
      ['x', [1557014400000, 1559779200000, 1562457600000], null],
    ]}
    config="timeseries"
    xAxisDataLabel="x"
  />
);
