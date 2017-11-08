import reducer from './index';
import * as types from '../../../consts';
import {
  initialState,
  request,
  stateBeforeResponse,
  response,
  stateAfterSuccess,
  stateAfterFailure,
  error,
} from './powerStatus.fixtures';

describe('powerStatus reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle HOST_POWER_STATUS_REQUEST', () => {
    expect(
      reducer(initialState, {
        type: types.HOST_POWER_STATUS_REQUEST,
        payload: request,
      })
    ).toEqual(stateBeforeResponse);
  });

  it('should handle HOST_POWER_STATUS_SUCCESS', () => {
    expect(
      reducer(stateBeforeResponse, {
        type: types.HOST_POWER_STATUS_SUCCESS,
        payload: response,
      })
    ).toEqual(stateAfterSuccess);
  });

  it('should handle HOST_POWER_STATUS_FAILURE', () => {
    expect(
      reducer(stateBeforeResponse, {
        type: types.HOST_POWER_STATUS_FAILURE,
        payload: { error, id: request.id },
      })
    ).toEqual(stateAfterFailure);
  });
});
