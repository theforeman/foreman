import { API } from '../../../redux/API';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  initializeEditor,
  importFile,
  revertChanges,
  previewTemplate,
  toggleModal,
  changeDiffViewType,
  changeEditorValue,
  dismissErrorToast,
  changeTab,
  toggleMaskValue,
  changeSetting,
  toggleRenderView,
  onSearchClear,
  onHostSelectToggle,
  onHostSearch,
} from '../EditorActions';

import {
  editorOptions,
  serverRenderResponse,
  hostsResponse,
} from '../Editor.fixtures';

jest.mock('../../../redux/API');

const runWithGetState = (state, params, action) => async dispatch => {
  const getState = () => ({
    editor: state,
  });
  await action(params)(dispatch, getState);
};

const runRenderTemplate = (state, serverMock) => {
  API.post.mockImplementation(serverMock);
  const host = {
    id: 1,
    name: 'host',
  };

  return runWithGetState(
    state,
    { host, renderPath: 'some/url' },
    previewTemplate
  );
};

const runOnHostSearch = (state, serverMock) => {
  API.post.mockImplementation(serverMock);

  return runWithGetState(state, { target: { value: 'host' } }, onHostSearch);
};

const e = { target: { files: [new File([new Blob()], 'filename')] } };

const fixtures = {
  'should initializeEditor': () =>
    initializeEditor({
      ...editorOptions,
      isMasked: true,
      selectedView: 'preview',
      isRendering: true,
      ...editorOptions.data,
      locked: true,
      type: 'templates',
    }),

  'should initializeEditor unlocked': () =>
    initializeEditor({
      ...editorOptions,
      previewResult: 'previewResult',
      isMasked: true,
      selectedView: 'preview',
      isRendering: true,
    }),

  'should importFile': () => importFile(e),

  'should toggleModal': () => toggleModal(),

  'should change mode to Html': () => changeSetting({ mode: 'Html' }),

  'should changeDiffViewType': () => changeDiffViewType('unified'),

  'should changeEditorValue': () => changeEditorValue('</>'),

  'should dismissErrorToast': () => dismissErrorToast(),

  'should changeTab': () => changeTab('diff'),

  'should revertChanges': () => revertChanges('<template />'),

  'should toggleMaskValue': () => toggleMaskValue(),

  'should toggleRenderView': () => toggleRenderView(),

  'should onSearchClear': () => onSearchClear(),

  'should onHostSelectToggle': () => onHostSelectToggle(),

  'should previewTemplate and succeed': () =>
    runRenderTemplate(
      { value: 'value', showError: false },
      async () => serverRenderResponse
    ),
  'should previewTemplate and fail': () =>
    runRenderTemplate({ value: 'value', showError: false }, async () => {
      throw new Error('some-error');
    }),

  'should onHostSearch and succeed': () =>
    runOnHostSearch({}, async () => hostsResponse),
  'should onHostSearch and fail': () =>
    runOnHostSearch({}, async () => {
      throw new Error('some-error');
    }),
};

describe('Editor actions', () => testActionSnapshotWithFixtures(fixtures));
