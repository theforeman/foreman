import TimeseriesChart from './';
import { timeseriesChartConfig } from '../../../../../services/ChartService.consts';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

jest.unmock('./');
const fixtures = {
  'render timeseries chart': {
    data: null,
    getConfig: () => Object.assign({}, {
      ...timeseriesChartConfig,
      data: {
        x: 'time',
        columns: [['time', 15029999123], ['Runtime', 8], ['Config Retrieval', 35]],
      },
    }),
  },
  'render empty timeseries chart': {
    data: null,
    getConfig: () => timeseriesChartConfig,
  },
};
testComponentSnapshotsWithFixtures(TimeseriesChart, fixtures);
