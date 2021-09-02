import { testReducerSnapshotWithFixtures } from '@theforeman/test';
import Immutable from 'seamless-immutable';
import reducer from '../FillReducer';
import { REMOVE_FILLED_COMPONENT } from '../FillConstants';

const initState = Immutable({
  slot: { fill1: { weight: 100 }, fill2: { weight: 200 } },
});

const fixtures = {
  'should removed a fill': {
    state: initState,
    action: {
      type: REMOVE_FILLED_COMPONENT,
      payload: { fillId: 'fill1', slotId: 'slot' },
    },
  },
};

describe('FillReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
