import Immutable from 'seamless-immutable';
import {
  DIFF_MODAL_TOGGLE,
  DIFF_MODAL_CREATE,
  DIFF_MODAL_VIEWTYPE,
} from '../DiffModalConstants';
import reducer from '../DiffModalReducer';
import { diffModalMock } from '../DiffModal.fixtures';

const initialState = Immutable({
  isOpen: false,
  diff: '',
  title: '',
  diffViewType: 'split',
});

describe('DiffModal reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('handles DIFF_MODAL_TOGGLE', () => {
    expect(reducer(initialState, { type: DIFF_MODAL_TOGGLE })).toEqual({
      ...initialState,
      isOpen: true,
    });
  });

  it('handles DIFF_MODAL_CREATE', () => {
    expect(
      reducer(initialState, {
        type: DIFF_MODAL_CREATE,
        payload: {
          diff: diffModalMock.diff,
          title: diffModalMock.title,
          isOpen: true,
        },
      })
    ).toEqual({
      ...initialState,
      diff: diffModalMock.diff,
      title: diffModalMock.title,
      isOpen: true,
    });
  });

  it('handles DIFF_MODAL_VIEWTYPE', () => {
    expect(
      reducer(initialState, {
        type: DIFF_MODAL_VIEWTYPE,
        payload: {
          diffViewType: 'unified',
        },
      })
    ).toEqual({
      ...initialState,
      diffViewType: 'unified',
    });
  });
});
