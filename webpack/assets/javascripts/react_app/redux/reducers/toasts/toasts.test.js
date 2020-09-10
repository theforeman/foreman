import * as types from '../../consts';

import {
  initialState,
  messageBeforeAdd,
  stateAfterAdd,
} from './toasts.fixtures';

import reducer from './index';

describe('toasts reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle TOASTS_ADD', () => {
    expect(
      reducer(initialState, {
        type: types.TOASTS_ADD,
        payload: {
          key: '1',
          message: messageBeforeAdd,
        },
      })
    ).toEqual(stateAfterAdd);
  });

  it('should handle TOASTS_DELETE', () => {
    expect(
      reducer(stateAfterAdd, {
        type: types.TOASTS_DELETE,
        payload: { key: '1' },
      })
    ).toEqual(initialState);
  });

  it('should handle TOASTS_CLEAR', () => {
    expect(
      reducer(stateAfterAdd, {
        type: types.TOASTS_CLEAR,
      })
    ).toEqual(initialState);
  });
});
