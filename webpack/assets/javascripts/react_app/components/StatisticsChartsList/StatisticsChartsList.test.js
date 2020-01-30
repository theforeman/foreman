import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import StatisticsChartsList from './';
import { statisticsData } from './StatisticsChartsList.fixtures';

const fixtures = {
  'should render no panels for empty data': {
    data: {},
  },
  'should render two panels for fixtures data': {
    data: statisticsData,
  },
};

describe('StatisticsChartsList', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(StatisticsChartsList, fixtures));
});
