import React from 'react';

import LineChart from './index';
import { data, timeseriesData } from './LineChart.fixtures';
import Story from '../../../../../../../stories/components/Story';

export default {
  title: 'Components|Charts|LineChart',
};

export const lineChart = () => (
  <Story>
    <LineChart data={data} />
  </Story>
);

export const lineChartTimeseries = () => (
  <Story>
    <LineChart data={timeseriesData} config="timeseries" xAxisDataLabel="x" />
  </Story>
);

lineChartTimeseries.story = {
  name: 'Line Chart timeseries',
};
