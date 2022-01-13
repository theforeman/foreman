import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './EditorActions';
import reducer from './EditorReducer';

import Editor from './Editor';

import {
  navFilteredHostsSelector,
  navHostsSelector,
  selectChosenHost,
  selectChosenView,
  selectDiffType,
  selectEditorName,
  selectErrorText,
  selectIsFetchingHosts,
  selectIsLoading,
  selectIsMasked,
  selectIsMaximized,
  selectIsReadOnly,
  selectIsRendering,
  selectIsSearchingHosts,
  selectIsSelectOpen,
  selectKeyBind,
  selectMode,
  selectPreviewResult,
  selectRenderedEditorValue,
  selectSearchQuery,
  selectShowError,
  selectTheme,
  selectValue,
  selectTemplateKindId,
} from './EditorSelectors';

// map state to props
const mapStateToProps = state => ({
  diffViewType: selectDiffType(state),
  editorName: selectEditorName(state),
  errorText: selectErrorText(state),
  filteredHosts: navFilteredHostsSelector(state),
  hosts: navHostsSelector(state),
  isFetchingHosts: selectIsFetchingHosts(state),
  isLoading: selectIsLoading(state),
  isMasked: selectIsMasked(state),
  isMaximized: selectIsMaximized(state),
  isRendering: selectIsRendering(state),
  isSearchingHosts: selectIsSearchingHosts(state),
  isSelectOpen: selectIsSelectOpen(state),
  keyBinding: selectKeyBind(state),
  mode: selectMode(state),
  previewResult: selectPreviewResult(state),
  renderedEditorValue: selectRenderedEditorValue(state),
  readOnly: selectIsReadOnly(state),
  searchQuery: selectSearchQuery(state),
  selectedHost: selectChosenHost(state),
  selectedView: selectChosenView(state),
  showError: selectShowError(state),
  theme: selectTheme(state),
  value: selectValue(state),
  templateKindId: selectTemplateKindId(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { editor: reducer };

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(Editor);
