import { createSelector } from 'reselect';
import { EDITOR_HOST_ARR, EDITOR_HOST_FILTERED_ARR } from './EditorConstants';

export const selectEditor = (state) => state.editor;

export const selectValue = (state) => selectEditor(state).value;
export const selectPreviewResult = (state) => selectEditor(state).previewResult;
export const selectErrorText = (state) => selectEditor(state).errorText;
export const selectMode = (state) => selectEditor(state).mode;
export const selectKeyBind = (state) => selectEditor(state).keyBinding;
export const selectEditorName = (state) => selectEditor(state).editorName;
export const selectChosenView = (state) => selectEditor(state).selectedView;
export const selectTheme = (state) => selectEditor(state).theme;
export const selectDiffType = (state) => selectEditor(state).diffViewType;
export const selectIsMaximized = (state) => selectEditor(state).isMaximized;
export const selectIsMasked = (state) => selectEditor(state).isMasked;
export const selectIsRendering = (state) => selectEditor(state).isRendering;
export const selectIsLoading = (state) => selectEditor(state).isLoading;
export const selectIsReadOnly = (state) => selectEditor(state).readOnly;
export const selectShowError = (state) => selectEditor(state).showError;
export const selectTemplateClass = (state) => selectEditor(state).templateClass;
export const selectRenderedEditorValue = (state) =>
  selectEditor(state).renderedEditorValue;

// Select
export const selectHosts = (state) => selectEditor(state)[EDITOR_HOST_ARR];
export const selectFilteredHosts = (state) =>
  selectEditor(state)[EDITOR_HOST_FILTERED_ARR];
export const selectIsSearchingHosts = (state) =>
  selectEditor(state).isSearchingHosts;
export const selectChosenHost = (state) => selectEditor(state).selectedHost;
export const selectIsSelectOpen = (state) => selectEditor(state).isSelectOpen;
export const selectSearchQuery = (state) => selectEditor(state).searchQuery;
export const selectIsFetchingHosts = (state) =>
  selectEditor(state).isFetchingHosts;

export const navHostsSelector = createSelector(selectHosts, (hosts) =>
  navHosts(hosts)
);

export const navFilteredHostsSelector = createSelector(
  selectFilteredHosts,
  (hosts) => navHosts(hosts)
);

const navHosts = (hosts) => {
  if (hosts)
    return hosts.map((host) => ({ id: host.id.toString(), name: host.name }));
  return [];
};
