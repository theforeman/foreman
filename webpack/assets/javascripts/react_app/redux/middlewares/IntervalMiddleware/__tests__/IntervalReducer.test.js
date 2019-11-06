import Immutable from 'seamless-immutable';
import { START_INTERVAL, STOP_INTERVAL } from '../IntervalConstants';
import { reducer } from '../IntervalReducer';

import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  key,
  intervalID,
  stateWithKey,
  initialState,
} from '../IntervalFixtures';

const fixtures = {
  'should return the initial state': initialState,
  'should handle START_INTERVAL': {
    action: {
      type: START_INTERVAL,
      payload: {
        key,
        intervalID,
      },
    },
  },
};

describe('API reducer', () => {
  testReducerSnapshotWithFixtures(reducer, fixtures);

  it('Should handle STOP_INTERVAL', () => {
    const state = Immutable(stateWithKey);
    const stopAction = {
      type: STOP_INTERVAL,
      payload: {
        key,
      },
    };

    expect(reducer(state, stopAction)).toMatchSnapshot();
  });
});
