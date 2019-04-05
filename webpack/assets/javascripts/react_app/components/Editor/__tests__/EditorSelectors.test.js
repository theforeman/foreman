import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectEditor,
  selectRenderedEditorValue,
  selectValue,
  selectHosts,
  selectChosenHost,
  selectPreviewResult,
  selectErrorText,
  selectMode,
  selectKeyBind,
  selectEditorName,
  selectChosenView,
  selectTheme,
  selectDiffType,
  selectIsMaximized,
  selectIsMasked,
  selectIsRendering,
  selectIsLoading,
  selectIsFetchingHosts,
  selectIsReadOnly,
  selectShowError,
  navHostsSelector,
  navFilteredHostsSelector,
  selectFilteredHosts,
  selectIsSearchingHosts,
  selectIsSelectOpen,
  selectSearchQuery,
  selectTemplateClass,
} from '../EditorSelectors';
import { editorOptions } from '../Editor.fixtures';

const state = {
  editor: {
    ...editorOptions,
  },
};

const fixtures = {
  'should return editor': () => selectEditor(state),
  'should return selected host': () => selectChosenHost(state),
  'should return selectPreviewResult': () => selectPreviewResult(state),
  'should return selectErrorText': () => selectErrorText(state),
  'should return selectMode': () => selectMode(state),
  'should return selectKeyBind': () => selectKeyBind(state),
  'should return selectEditorName': () => selectEditorName(state),
  'should return selectChosenView': () => selectChosenView(state),
  'should return selectTheme': () => selectTheme(state),
  'should return selectDiffType': () => selectDiffType(state),
  'should return selectIsMaximized': () => selectIsMaximized(state),
  'should return selectIsMasked': () => selectIsMasked(state),
  'should return selectIsRendering': () => selectIsRendering(state),
  'should return selectIsLoading': () => selectIsLoading(state),
  'should return selectIsFetchingHosts': () => selectIsFetchingHosts(state),
  'should return selectIsReadOnly': () => selectIsReadOnly(state),
  'should return selectShowError': () => selectShowError(state),
  'should return selectRenderedEditorValue': () =>
    selectRenderedEditorValue(state),
  'should return selectValue': () => selectValue(state),
  'should return selectHosts': () => selectHosts(state),
  'should return selectFilteredHosts': () => selectFilteredHosts(state),
  'should return componentHosts': () => navHostsSelector(state),
  'should return filtered componentHosts': () =>
    navFilteredHostsSelector(state),
  'should return componentHosts w/Empty Arr': () =>
    navHostsSelector({ editor: { hosts: undefined } }),
  'should return selectIsSearchingHosts': () => selectIsSearchingHosts(state),
  'should return selectIsSelectOpen': () => selectIsSelectOpen(state),
  'should return selectSearchQuery': () => selectSearchQuery(state),
  'should return selectTemplateClass': () => selectTemplateClass(state),
};

describe('Editor selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
