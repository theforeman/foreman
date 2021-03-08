import { debounce, toString } from 'lodash';
import { API } from '../../redux/API';
import { translate as __ } from '../../common/I18n';

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
  EDITOR_HOSTS_URL,
  EDITOR_HOST_SELECT_TOGGLE,
  EDITOR_HOST_SELECT_CLEAR,
  EDITOR_FETCH_HOST_PENDING,
  EDITOR_FETCH_HOST_RESOLVED,
  EDITOR_HOST_SELECT_RESET,
  EDITOR_HOST_ARR,
  EDITOR_HOST_FILTERED_ARR,
} from './EditorConstants';

import {
  selectTemplateClass,
  selectValue,
  selectShowError,
  selectIsSelectOpen,
  selectHosts,
} from './EditorSelectors';

import { parseDocs } from './EditorHelpers';

export const initializeEditor = initializeData => dispatch => {
  const {
    template,
    locked,
    type,
    templateClass,
    readOnly,
    isMasked,
    selectedView,
    isRendering,
    previewResult,
    showError,
    dslCache,
  } = initializeData;

  const initialState = {};
  // initialize after changing editors
  initialState.selectedHost = { id: '', name: '' };
  initialState.hosts = [];
  initialState.isSearchingHosts = false;
  initialState.value = template || '';
  initialState.templateClass = templateClass;
  if (readOnly !== locked) {
    if (locked === true) initialState.readOnly = true;
    else initialState.readOnly = false;
  }
  if (isMasked && type === 'templates') initialState.isMasked = false;
  if (selectedView !== 'input') initialState.selectedView = 'input';
  if (isRendering) initialState.isRendering = false;
  if (previewResult !== '') initialState.previewResult = '';
  if (showError) initialState.showError = false;
  parseDocs(dslCache);
  dispatch({
    type: EDITOR_INITIALIZE,
    payload: initialState,
  });
};

export const importFile = e => dispatch => {
  const reader = new FileReader();
  reader.onloadstart = () => dispatch({ type: EDITOR_SHOW_LOADING });
  reader.onloadend = () => dispatch({ type: EDITOR_HIDE_LOADING });
  reader.onload = event => {
    dispatch({
      type: EDITOR_IMPORT_FILE,
      payload: {
        value: event.target.result,
      },
    });
  };
  reader.readAsText(e.target.files[0]);
};

export const revertChanges = template => dispatch => {
  dispatch({
    type: EDITOR_REVERT_CHANGES,
    payload: {
      value: template || '',
      isRendering: false,
    },
  });
};

export const previewTemplate = ({ host, renderPath }) => async (
  dispatch,
  getState
) => {
  const { id, name } = host;
  if (selectIsSelectOpen(getState()))
    dispatch({ type: EDITOR_HOST_SELECT_TOGGLE });
  const templateValue = selectValue(getState());
  const isErrorShown = selectShowError(getState());

  const params = {
    template: templateValue,
    /* eslint-disable camelcase */
    preview_host_id: id,
  };
  dispatch({ type: EDITOR_SHOW_LOADING });
  try {
    const response = await fetchTemplatePreview(renderPath, params);
    if (isErrorShown) dispatch(dismissErrorToast());
    dispatch({ type: EDITOR_HIDE_LOADING });
    dispatch({
      type: EDITOR_EXEC_PREVIEW,
      payload: {
        renderedEditorValue: templateValue,
        selectedHost: {
          id: toString(id),
          name,
        },
        previewResult: response.data,
        isSearchingHosts: false,
      },
    });
  } catch (error) {
    dispatch({ type: EDITOR_HIDE_LOADING });
    dispatch({
      type: EDITOR_SHOW_ERROR,
      payload: {
        renderedEditorValue: templateValue,
        showError: true,
        errorText: error.response ? __(error.response.data) : '',
        previewResult: __('Error during rendering, Return to Editor tab.'),
        selectedHost: {
          id: toString(id),
          name,
        },
      },
    });
  }
};

export const fetchTemplatePreview = (renderPath, params) =>
  API.post(renderPath, params);

// fetch & debounced fetch
const fetchHosts = (
  query = '',
  array = EDITOR_HOST_ARR,
  url = EDITOR_HOSTS_URL
) => (dispatch, getState) =>
  createHostAPIRequest(query, array, url, dispatch, getState);

const debouncedFetchHosts = (
  query = '',
  array = EDITOR_HOST_ARR,
  url = EDITOR_HOSTS_URL
) => (dispatch, getState) =>
  debouncedCreateHostAPIRequest(query, array, url, dispatch, getState);

// API & debounced API
const createHostAPIRequest = async (query, array, url, dispatch, getState) => {
  const onResultsSuccess = response =>
    dispatch({
      type: EDITOR_FETCH_HOST_RESOLVED,
      payload: { [array]: response.data },
    });

  const onResultsError = response =>
    dispatch({
      type: EDITOR_SHOW_ERROR,
      payload: {
        showError: true,
        errorText: __(`Host Fetch ${response}`),
        previewResult: __('Error during rendering, Return to Editor tab.'),
      },
    });

  try {
    const response = await API.get(
      url,
      {},
      { q: query, scope: selectTemplateClass(getState()) }
    );
    return onResultsSuccess(response);
  } catch (error) {
    return onResultsError(error);
  }
};
const debouncedCreateHostAPIRequest = debounce(createHostAPIRequest, 250);

export const onHostSearch = e => (dispatch, getState) => {
  if (e.target.value === '')
    return dispatch({ type: EDITOR_HOST_SELECT_RESET });

  const payload = {
    isFetchingHosts: true,
    searchQuery: e.target.value,
    isSearchingHosts: true,
  };

  dispatch({ type: EDITOR_FETCH_HOST_PENDING, payload });
  return dispatch(
    debouncedFetchHosts(e.target.value, EDITOR_HOST_FILTERED_ARR)
  );
};

export const fetchAndPreview = renderPath => async (dispatch, getState) => {
  dispatch({ type: EDITOR_SHOW_LOADING });
  await dispatch(fetchHosts());
  const hosts = selectHosts(getState());
  if (hosts.length > 0)
    dispatch(previewTemplate({ host: hosts[0], renderPath }));
  else dispatch({ type: EDITOR_HIDE_LOADING });
};

export const toggleModal = () => ({
  type: EDITOR_MODAL_TOGGLE,
});

export const changeDiffViewType = viewType => dispatch => {
  dispatch({
    type: EDITOR_CHANGE_DIFF_VIEW,
    payload: viewType,
  });
};

export const changeEditorValue = value => dispatch => {
  dispatch({
    type: EDITOR_CHANGE_VALUE,
    payload: value,
  });
};

export const dismissErrorToast = () => dispatch => {
  dispatch({
    type: EDITOR_DISMISS_ERROR,
    payload: { showError: false, errorText: '' },
  });
};

export const changeTab = selectedView => dispatch => {
  dispatch({
    type: EDITOR_CHANGE_TAB,
    payload: selectedView,
  });
};

export const toggleMaskValue = () => ({
  type: EDITOR_TOGGLE_MASK,
});

export const changeSetting = newSetting => dispatch => {
  dispatch({
    type: EDITOR_CHANGE_SETTING,
    payload: newSetting,
  });
};

export const toggleRenderView = isRendering => ({
  type: EDITOR_TOGGLE_RENDER_VIEW,
});

export const onSearchClear = () => ({ type: EDITOR_HOST_SELECT_CLEAR });

export const onHostSelectToggle = () => ({
  type: EDITOR_HOST_SELECT_TOGGLE,
});
