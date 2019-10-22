import { API_OPERATIONS } from '../APIConstants';
import { reducer } from '../APIReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  key,
  APIRequest,
  polling,
  initialState,
  stateWithKey,
} from '../APIFixtures';

const { START_POLLING, STOP_POLLING } = API_OPERATIONS;

const fixtures = {
  'should return the initial state': initialState,
  'should handle START_POLLING': {
    action: {
      type: START_POLLING,
      key,
      payload: {
        APIRequest,
        polling,
      },
    },
  },
};

describe('API reducer', () => {
  testReducerSnapshotWithFixtures(reducer, fixtures);

  it('Should handle STOP_POLLING', () => {
    const stopAction = {
      type: STOP_POLLING,
      key,
    };
    expect(reducer(stateWithKey, stopAction)).toMatchSnapshot();
  });
});
