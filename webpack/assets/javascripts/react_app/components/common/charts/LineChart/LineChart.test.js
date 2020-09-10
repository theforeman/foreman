import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import { data, timeseriesData } from './LineChart.fixtures';
import LineChart from './index';

jest.mock('../../../../../services/charts/ChartService.consts');

const fixtures = {
  'should render line chart': {
    data,
    id: 'abc',
  },
  'should render line chart with timeseries': {
    data: timeseriesData,
    xAxisDataLabel: 'x',
    config: 'timeseries',
    id: 'xyz',
  },
};

describe('Line Chart', () =>
  testComponentSnapshotsWithFixtures(LineChart, fixtures));
