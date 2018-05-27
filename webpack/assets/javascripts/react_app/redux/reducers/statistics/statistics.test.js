import * as types from '../../consts';

import {
  initialState,
  request,
  stateBeforeResponse,
  response,
  error,
} from './statistics.fixtures';

import reducer from './index';
import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

describe('statistics reducer', () => {
  const fixtures = {
    'should return the initial state': {
      prev: undefined,
      action: {},
    },
    'should handle STATISTICS_DATA_REQUEST': {
      prev: initialState,
      action: {
        type: types.STATISTICS_DATA_REQUEST,
        payload: request,
      },
    },
    'should handle STATISTICS_DATA_SUCCESS': {
      prev: stateBeforeResponse,
      action: {
        type: types.STATISTICS_DATA_SUCCESS,
        payload: response,
      },
    },
    'should handle STATISTICS_DATA_FAILURE': {
      prev: stateBeforeResponse,
      action: {
        type: types.STATISTICS_DATA_FAILURE,
        payload: { error, item: request },
      },
    },
  };
  testReducerSnapshotWithFixtures(reducer, fixtures);
});
