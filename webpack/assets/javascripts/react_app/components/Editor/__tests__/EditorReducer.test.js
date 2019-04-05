import {
  EDITOR_CHANGE_DIFF_VIEW,
  EDITOR_CHANGE_SETTING,
  EDITOR_CHANGE_TAB,
  EDITOR_CHANGE_VALUE,
  EDITOR_DISMISS_ERROR,
  EDITOR_SHOW_ERROR,
  EDITOR_EXEC_PREVIEW,
  EDITOR_IMPORT_FILE,
  EDITOR_INITIALIZE,
  EDITOR_MODAL_TOGGLE,
  EDITOR_REVERT_CHANGES,
  EDITOR_TOGGLE_MASK,
  EDITOR_TOGGLE_RENDER_VIEW,
  EDITOR_HOST_SELECT_CLEAR,
  EDITOR_HOST_SELECT_TOGGLE,
  EDITOR_FETCH_HOST_PENDING,
  EDITOR_HOST_SELECT_RESET,
  EDITOR_FETCH_HOST_RESOLVED,
  EDITOR_HOST_INITIAL_FETCH,
  EDITOR_SHOW_LOADING,
  EDITOR_HIDE_LOADING,
} from '../EditorConstants';

import reducer from '../EditorReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should return the initial state': {},
  'should handle EDITOR_INITIALIZE': {
    action: {
      type: EDITOR_INITIALIZE,
      payload: { value: 'newValue' },
    },
  },
  'should handle EDITOR_CHANGE_STATE': {
    action: {
      type: EDITOR_CHANGE_VALUE,
      payload: '< newValue />',
    },
  },
  'should handle EDITOR_IMPORT_FILE': {
    action: {
      type: EDITOR_IMPORT_FILE,
      payload: {
        value: '</>',
      },
    },
  },
  'should handle EDITOR_REVERT_CHANGES': {
    action: {
      type: EDITOR_REVERT_CHANGES,
      payload: {
        value: '</>',
      },
    },
  },
  'should handle EDITOR_EXEC_PREVIEW': {
    action: {
      type: EDITOR_EXEC_PREVIEW,
      payload: {
        previewResult: '</>',
      },
    },
  },
  'should handle EDITOR_MODAL_TOGGLE': {
    action: {
      type: EDITOR_MODAL_TOGGLE,
    },
  },
  'should handle EDITOR_CHANGE_DIFF_VIEW': {
    action: {
      type: EDITOR_CHANGE_DIFF_VIEW,
      payload: 'unified',
    },
  },
  'should handle EDITOR_SHOW_ERROR': {
    action: {
      type: EDITOR_SHOW_ERROR,
      payload: {
        showError: true,
        errorText: 'error',
        previewResult: 'error',
      },
    },
  },
  'should handle EDITOR_DISMISS_ERROR': {
    action: {
      type: EDITOR_DISMISS_ERROR,
      payload: { showError: false, errorText: '' },
    },
  },
  'should handle EDITOR_CHANGE_TAB': {
    action: {
      type: EDITOR_CHANGE_TAB,
      payload: 'diff',
    },
  },
  'should handle EDITOR_TOGGLE_MASK': {
    action: {
      type: EDITOR_TOGGLE_MASK,
    },
  },
  'should handle EDITOR_TOGGLE_RENDER_VIEW': {
    action: {
      type: EDITOR_TOGGLE_RENDER_VIEW,
    },
  },
  'should handle EDITOR_HOST_SELECT_CLEAR': {
    action: {
      type: EDITOR_HOST_SELECT_CLEAR,
    },
  },
  'should handle EDITOR_CHANGE_SETTING': {
    action: {
      type: EDITOR_CHANGE_SETTING,
      payload: { mode: 'html' },
    },
  },
  'should handle EDITOR_SHOW_LOADING': {
    action: {
      type: EDITOR_SHOW_LOADING,
    },
  },
  'should handle EDITOR_HIDE_LOADING': {
    action: {
      type: EDITOR_HIDE_LOADING,
    },
  },
  'should handle EDITOR_HOST_INITIAL_FETCH': {
    action: {
      type: EDITOR_HOST_INITIAL_FETCH,
      payload: [{ id: '1', name: 'html' }],
    },
  },
  'should handle EDITOR_HOST_SELECT_TOGGLE': {
    action: {
      type: EDITOR_HOST_SELECT_TOGGLE,
    },
  },
  'should handle EDITOR_HOST_SELECT_RESET': {
    action: {
      type: EDITOR_HOST_SELECT_RESET,
    },
  },
  'should handle EDITOR_FETCH_HOST_RESOLVED': {
    action: {
      type: EDITOR_FETCH_HOST_RESOLVED,
      payload: {
        hosts: [{ id: '1', name: 'html' }],
      },
    },
  },
  'should handle EDITOR_FETCH_HOST_PENDING': {
    action: {
      type: EDITOR_FETCH_HOST_PENDING,
      payload: {
        isFetchingHosts: true,
        searchQuery: 'value',
        isSearchingHosts: true,
      },
    },
  },
};
describe('Editor reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
