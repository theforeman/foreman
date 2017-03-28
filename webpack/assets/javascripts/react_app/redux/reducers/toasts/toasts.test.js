import reducer from './index';
import * as types from '../../consts';
import {
  initialState,
  messageBeforeAdd,
  stateAfterAdd,
  stateAfterHide,
  stateAfterDelete
} from './toasts.fixtures';

describe('toasts reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle TOASTS_ADD', () => {
    expect(reducer(initialState, {
      type: types.TOASTS_ADD,
      payload: messageBeforeAdd
    })).toEqual(stateAfterAdd);
  });

  it('should handle TOASTS_ADD', () => {
    expect(reducer(stateAfterAdd, {
      type: types.TOASTS_HIDE,
      payload: { id: '1' }
    })).toEqual(stateAfterHide);
  });

  it('should handle TOASTS_DELETE', () => {
    expect(reducer(stateAfterAdd, {
      type: types.TOASTS_DELETE,
      payload: { id: '1' }
    })).toEqual(stateAfterDelete);
  });
});
