import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';
import { chartDataValues } from '../FactChart.fixtures';

import reducer from '../FactChartReducer';

import * as types from '../FactChartConstants';

const fixtures = {
  'initial state': {},
  'should handle FACT_CHART_REQUEST action': {
    action: { type: types.FACT_CHART_REQUEST, payload: { id: 1 } },
  },
  'should handle FACT_CHART_SUCCESS action': {
    action: {
      type: types.FACT_CHART_SUCCESS,
      payload: { values: chartDataValues },
    },
  },
  'should handle FACT_CHART_ERROR action': {
    action: {
      type: types.FACT_CHART_FAILURE,
      payload: {},
    },
  },
  'should not display modal': {
    action: {
      type: types.FACT_CHART_MODAL_CLOSE,
      payload: {},
    },
  },
};

describe('FactChart reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
