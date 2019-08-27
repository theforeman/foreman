import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';

import { getLineChartConfig } from './LineChartService';
import {
  data,
  timeseriesData,
} from '../../react_app/components/common/charts/LineChart/LineChart.fixtures';

jest.unmock('./LineChartService');
jest.unmock('./ChartService');

const fixtures = {
  'should get regular config': () =>
    getLineChartConfig({
      data,
      config: 'regular',
      onclick: () => {},
      id: 'klm',
    }),
  'should get timeseries config': () =>
    getLineChartConfig({
      data: timeseriesData,
      config: 'timeseries',
      onclick: () => {},
      xAxisDataLabel: 'x',
      id: 'pqr',
    }),
};

describe('getLineChartConfig', () => testActionSnapshotWithFixtures(fixtures));
