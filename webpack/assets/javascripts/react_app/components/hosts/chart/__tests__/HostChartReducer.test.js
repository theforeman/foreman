import { TIMESERIES_REQUEST, TIMESERIES_FAILURE, TIMESERIES_SUCCESS } from '../HostChartConsts';
import reducer from '../HostChartReducer';
import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';

const fixtures = {
  'should handle empty action': {},
  'should handle TIMESERIES_REQUEST': {
    action: {
      type: TIMESERIES_REQUEST,
      payload: {
        name: 'ts1',
        results: [{ label: 'data', data: [[1, 1], [2, 2]] }],
      },
    },
  },
  'should handle TIMESERIES_FAILURE': {
    action: {
      type: TIMESERIES_FAILURE,
      payload: { error: new Error('Oops, something is wrong'), item: { name: 'ts1' } },
    },
  },
  'should handle TIMESERIES_SUCCESS': {
    action: {
      type: TIMESERIES_SUCCESS,
      payload: {
        name: 'ts1',
        results: [{
          label: 'data-1',
          data: [[10, 20], [20, 20], [30, 0]],
          color: 'blue',
        }, {
          label: 'data-2',
          data: [[10, 0], [20, 0], [30, 0]],
        }],
      },
    },
  },
};

describe('TimeseriesChart reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
