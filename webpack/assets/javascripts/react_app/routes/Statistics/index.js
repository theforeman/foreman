import React from 'react';
import StatisticsPage from './StatisticsPage';
import { STATISTICS_PAGE_URL } from './constants';

export default {
  path: STATISTICS_PAGE_URL,
  render: props => <StatisticsPage {...props} />,
};
