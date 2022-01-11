import { noop } from '../../common/helpers';

export const editor = {
  name: 'editor',
  diffViewType: 'split',
  value: 'value',
  previewValue: 'preview',
  renderedEditorValue: 'renderedEditorValue',
  hosts: [
    { id: '1', name: 'host1' },
    { id: '2', name: 'host2' },
  ],
  filteredHosts: [],
  previewResult: 'previewResult',
  mode: 'Ruby',
  theme: 'Monokai',
  keyBinding: 'Default',
  selectedView: 'input',
  editorName: 'editor',
  isMaximized: false,
  isMasked: false,
  isRendering: false,
  isLoading: false,
  isFetchingHosts: false,
  isSearchingHosts: false,
  readOnly: false,
  showError: true,
  errorText: '',
  selectedHost: { id: '', name: '' },
  isSelectOpen: false,
  searchQuery: '',
  template: '',
};

export const dropdowns = {
  modes: ['Text', 'Json', 'Ruby', 'Html_ruby', 'Sh', 'Xml', 'Yaml'],
  keyBindings: ['Default', 'Emacs', 'Vim'],
  themes: ['Github', 'Monokai'],
};

export const showBooleans = {
  showPreview: true,
  showHostSelector: true,
  showImport: true,
  showHide: true,
};

export const editorOptions = {
  ...editor,
  ...dropdowns,
  data: {
    ...showBooleans,
    name: 'editor',
    title: 'title',
    template: '<? />',
    options: dropdowns,
    isSafemodeEnabled: true,
    renderPath: '/render/path',
    safemodeRenderPath: '/safemoderender/path',
  },
  initializeEditor: noop,
  importFile: noop,
  revertChanges: noop,
  previewTemplate: noop,
  toggleModal: noop,
  changeDiffViewType: noop,
  changeEditorValue: noop,
  dismissErrorToast: noop,
  changeTab: noop,
  toggleMaskValue: noop,
  changeSetting: noop,
  toggleRenderView: noop,
  onHostSearch: noop,
  onHostSelectToggle: noop,
  onSearchClear: noop,
  fetchAndPreview: noop,
  template: '<? />',
};

export const serverRenderResponse = {
  data: ['< renderedData />'],
};

export const hosts = [
  { id: '1', name: 'host1' },
  { id: '2', name: 'host2' },
];
