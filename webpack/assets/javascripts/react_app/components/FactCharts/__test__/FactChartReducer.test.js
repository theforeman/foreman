import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

import reducer from '../FactChartReducer';
import { FACT_CHART_MODAL_CLOSE } from '../FactChartConstants';

const fixtures = {
  'initial state': {},
  'should not display modal': {
    action: {
      type: FACT_CHART_MODAL_CLOSE,
      payload: {},
    },
  },
};

describe('FactChart reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
