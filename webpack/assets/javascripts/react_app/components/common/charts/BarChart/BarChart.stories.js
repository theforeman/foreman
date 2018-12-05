import React from 'react';
import { storiesOf } from '@storybook/react';
import BarChart from './';
import { barChartData } from './BarChart.fixtures';
import Story from '../../../../../../../stories/components/Story';

storiesOf('Components/Charts', module).add('Bar Chart', () => (
  <Story>
    <BarChart {...barChartData} />
  </Story>
));
