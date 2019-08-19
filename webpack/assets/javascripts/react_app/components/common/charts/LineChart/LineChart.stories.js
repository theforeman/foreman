import React from 'react';

import { storiesOf } from '@storybook/react';

import LineChart from './index';
import { data, timeseriesData } from './LineChart.fixtures';
import Story from '../../../../../../../stories/components/Story';

storiesOf('Components/Charts', module)
  .add('Line Chart', () => (
    <Story>
      <LineChart data={data} />
    </Story>
  ))
  .add('Line Chart timeseries', () => (
    <Story>
      <LineChart data={timeseriesData} config="timeseries" xAxisDataLabel="x" />
    </Story>
  ));
