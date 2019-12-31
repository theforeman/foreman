import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import { chartDataValues } from '../FactChart.fixtures';

import reducer from '../FactChartReducer';
import { FACT_CHART, FACT_CHART_MODAL_CLOSE } from '../FactChartConstants';
import { actionTypeGenerator } from '../../../redux/API';

const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(FACT_CHART);

const fixtures = {
  'initial state': {},
  'should handle FACT_CHART_REQUEST action': {
    action: { type: REQUEST, payload: { id: 1 } },
  },
  'should handle FACT_CHART_SUCCESS action': {
    action: {
      type: SUCCESS,
      payload: { id: 1 },
      response: { values: chartDataValues },
    },
  },
  'should handle FACT_CHART_ERROR action': {
    action: {
      type: FAILURE,
      payload: {},
    },
  },
  'should not display modal': {
    action: {
      type: FACT_CHART_MODAL_CLOSE,
      payload: {},
    },
  },
};

describe('FactChart reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
