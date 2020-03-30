import Immutable from 'seamless-immutable';
import { testReducerSnapshotWithFixtures } from '@theforeman/test';
import { reducer } from '../DebounceReducer';
import { startDebounce, clearDebounce } from '../DebounceActions';
import {
  key,
  debounceID,
  stateWithKey,
  initialState,
} from '../DebounceFixtures';

const fixtures = {
  'should return the initial state': initialState,
  'should handle DEBOUNCE_START': {
    action: startDebounce({ key, debounceID }),
  },
};

describe('Debounce reducer', () => {
  testReducerSnapshotWithFixtures(reducer, fixtures);

  it('Should handle DEBOUNCE_CLEAR', () => {
    const state = Immutable(stateWithKey);
    const stopAction = clearDebounce(key);

    expect(reducer(state, stopAction)).toMatchSnapshot();
  });
});
