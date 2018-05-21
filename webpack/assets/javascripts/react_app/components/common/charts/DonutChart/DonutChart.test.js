import { mockStoryData, emptyData } from './DonutChart.fixtures';
import DonutChart from './';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

jest.unmock('./');
const fixtures = {
  'render donut chart': {
    data: null,
    getConfig: () => mockStoryData,
  },
  'render empty donut chart': {
    data: null,
    getConfig: () => emptyData,
  },
};
testComponentSnapshotsWithFixtures(DonutChart, fixtures);
