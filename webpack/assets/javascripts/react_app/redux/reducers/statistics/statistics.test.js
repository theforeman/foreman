import * as types from '../../consts';

import {
  initialState,
  request,
  stateBeforeResponse,
  response,
  stateAfterSuccess,
  stateAfterFailure,
  error,
} from './statistics.fixtures';

import reducer from './index';

describe('statistics reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle STATISTICS_DATA_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.STATISTICS_DATA_REQUEST,
      payload: request,
    })).toEqual(stateBeforeResponse);
  });

  it('should handle STATISTICS_DATA_SUCCESS', () => {
    expect(reducer(stateBeforeResponse, {
      type: types.STATISTICS_DATA_SUCCESS,
      payload: response,
    })).toEqual(stateAfterSuccess);
  });

  it('should handle STATISTICS_DATA_FAILURE', () => {
    expect(reducer(stateBeforeResponse, {
      type: types.STATISTICS_DATA_FAILURE,
      payload: { error, id: request.id },
    })).toEqual(stateAfterFailure);
  });
});
