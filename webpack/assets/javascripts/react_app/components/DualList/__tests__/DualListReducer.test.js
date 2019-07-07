import { DUAL_LIST_INIT, DUAL_LIST_CHANGE } from '../DualListConstants';
import reducer from '../DualListReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import * as mock from '../DualList.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should update state with initial data': {
    action: {
      type: DUAL_LIST_INIT,
      payload: mock.initialData,
    },
  },
  'should handle DUAL_LIST_CHANGE': {
    action: {
      type: DUAL_LIST_CHANGE,
      payload: mock.itemsChanged,
    },
  },
};

describe('DualList reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
