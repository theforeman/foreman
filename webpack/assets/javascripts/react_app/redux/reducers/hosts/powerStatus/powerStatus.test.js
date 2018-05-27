import * as types from '../../../consts';

import {
  initialState,
  request,
  stateBeforeResponse,
  response,
  error,
} from './powerStatus.fixtures';

import reducer from './index';
import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';

describe('powerStatus reducer', () => {
  const fixtures = {
    'should return the initial state': {
      state: undefined,
      action: {},
    },
    'should handle HOST_POWER_STATUS_REQUEST': {
      state: initialState,
      action: {
        type: types.HOST_POWER_STATUS_REQUEST,
        payload: request,
      },
    },
    'should handle HOST_POWER_STATUS_SUCCESS': {
      state: stateBeforeResponse,
      action: {
        type: types.HOST_POWER_STATUS_SUCCESS,
        payload: response,
      },
    },
    'should handle HOST_POWER_STATUS_FAILURE': {
      state: stateBeforeResponse,
      action: {
        type: types.HOST_POWER_STATUS_FAILURE,
        payload: { error, item: { id: request.id } },
      },
    },
  };
  testReducerSnapshotWithFixtures(reducer, fixtures);
});
