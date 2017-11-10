import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import { mockStoryData } from './PieChart.fixtures';

import PieChart from './index';

storiesOf('Charts', module).add('Donut Chart', () => (
  <PieChart onclick={action('clicked')} data={mockStoryData.config.data.columns} />
));
