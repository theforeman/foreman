import Immutable from 'seamless-immutable';
import { reducer } from '../IntervalReducer';

import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  key,
  intervalID,
  stateWithKey,
  initialState,
} from '../IntervalFixtures';
import { startIntervalAction, stopInterval } from '../IntervalActions';

const fixtures = {
  'should return the initial state': initialState,
  'should handle START_INTERVAL': {
    action: startIntervalAction(key, intervalID),
  },
};

describe('Interval reducer', () => {
  testReducerSnapshotWithFixtures(reducer, fixtures);

  it('Should handle STOP_INTERVAL', () => {
    const state = Immutable(stateWithKey);
    const stopAction = stopInterval(key);

    expect(reducer(state, stopAction)).toMatchSnapshot();
  });
});
