import Immutable from 'seamless-immutable';

import {
  EDITOR_CHANGE_DIFF_VIEW,
  EDITOR_CHANGE_SETTING,
  EDITOR_CHANGE_TAB,
  EDITOR_CHANGE_VALUE,
  EDITOR_DISMISS_ERROR,
  EDITOR_SHOW_ERROR,
  EDITOR_EXEC_PREVIEW,
  EDITOR_SHOW_LOADING,
  EDITOR_HIDE_LOADING,
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
  EDITOR_HOST_ARR,
  EDITOR_HOST_FILTERED_ARR,
  EDITOR_CHANGE_KIND,
} from './EditorConstants';

const initialState = Immutable({
  [EDITOR_HOST_ARR]: [],
  [EDITOR_HOST_FILTERED_ARR]: [],
  diffViewType: 'split',
  editorName: 'editor',
  errorText: '',
  isFetchingHosts: false,
  isLoading: false,
  isMasked: false,
  isMaximized: false,
  isRendering: false,
  isSearchingHosts: false,
  isSelectOpen: false,
  keyBinding: 'Default',
  mode: 'Ruby',
  previewResult: '',
  renderedEditorValue: '',
  readOnly: false,
  searchQuery: '',
  selectedHost: {
    id: '',
    name: '',
  },
  selectedView: 'input',
  showError: false,
  templateClass: '',
  theme: 'Monokai',
  autocompletion: true,
  liveAutocompletion: false,
  value: '',
  kind: '',
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case EDITOR_INITIALIZE: {
      return state.merge(payload);
    }

    case EDITOR_REVERT_CHANGES: {
      return state.merge(payload);
    }

    case EDITOR_IMPORT_FILE: {
      return state.set('value', payload.value);
    }

    case EDITOR_EXEC_PREVIEW: {
      return state.merge(payload);
    }

    case EDITOR_HOST_SELECT_CLEAR: {
      return state.set('searchQuery', '').set('isSearchingHosts', false);
    }

    case EDITOR_MODAL_TOGGLE: {
      return state.set('isMaximized', !state.isMaximized);
    }

    case EDITOR_CHANGE_DIFF_VIEW: {
      return state.set('diffViewType', payload);
    }

    case EDITOR_CHANGE_VALUE: {
      return state.set('value', payload);
    }

    case EDITOR_SHOW_ERROR: {
      return state.merge(payload);
    }

    case EDITOR_DISMISS_ERROR: {
      return state.merge(payload);
    }

    case EDITOR_CHANGE_TAB: {
      return state.set('selectedView', payload);
    }

    case EDITOR_CHANGE_SETTING: {
      return state.merge(payload);
    }

    case EDITOR_TOGGLE_MASK: {
      return state.set('isMasked', !state.isMasked);
    }

    case EDITOR_TOGGLE_RENDER_VIEW: {
      return state.set('isRendering', !state.isRendering);
    }

    case EDITOR_SHOW_LOADING: {
      return state.set('isLoading', true);
    }

    case EDITOR_HIDE_LOADING: {
      return state.set('isLoading', false);
    }

    case EDITOR_FETCH_HOST_PENDING: {
      return state.merge(payload);
    }

    case EDITOR_FETCH_HOST_RESOLVED: {
      return state.set('isFetchingHosts', false).merge(payload);
    }

    case EDITOR_HOST_INITIAL_FETCH: {
      return state.set('hosts', payload);
    }

    case EDITOR_HOST_SELECT_TOGGLE: {
      return state
        .set('isSelectOpen', !state.isSelectOpen)
        .set('searchQuery', '');
    }

    case EDITOR_HOST_SELECT_RESET: {
      return state
        .set('searchQuery', '')
        .set('isFetchingHosts', false)
        .set('isSearchingHosts', false);
    }

    case EDITOR_CHANGE_KIND: {
      return state.set('templateKindId', payload);
    }

    default:
      return state;
  }
};
