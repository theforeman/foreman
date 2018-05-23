import React from 'react';
import { storiesOf } from '@storybook/react';
import BarChart from './';
import { barChartData } from './BarChart.fixtures';

storiesOf('Components/Charts', module)
  .add('Bar Chart', () => <BarChart {...barChartData} />);
