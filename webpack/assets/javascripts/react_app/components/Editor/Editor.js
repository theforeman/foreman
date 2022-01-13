import React from 'react';
import PropTypes from 'prop-types';
import { ToastNotification } from 'patternfly-react';

import { noop } from '../../common/helpers';
import DiffView from '../DiffView/DiffView';
import EditorView from './components/EditorView';
import EditorNavbar from './components/EditorNavbar';
import EditorModal from './components/EditorModal';
import {
  EDITOR_THEMES,
  EDITOR_KEYBINDINGS,
  EDITOR_MODES,
} from './EditorConstants';
import './editor.scss';

class Editor extends React.Component {
  componentDidMount() {
    const {
      data: { hosts, templateClass, locked, template, type },
      initializeEditor,
      isMasked,
      isRendering,
      readOnly,
      previewResult,
      selectedView,
      showError,
    } = this.props;

    const initializeData = {
      hosts,
      isMasked,
      templateClass,
      isRendering,
      locked,
      readOnly,
      previewResult,
      selectedView,
      showError,
      template,
      type,
    };
    initializeEditor(initializeData);
  }

  render() {
    const {
      data: {
        name,
        isSafemodeEnabled,
        renderPath,
        safemodeRenderPath,
        showHide,
        showImport,
        showPreview,
        showHostSelector,
        template,
        title,
      },
      changeDiffViewType,
      changeEditorValue,
      changeSetting,
      changeTab,
      diffViewType,
      dismissErrorToast,
      editorName,
      errorText,
      fetchAndPreview,
      filteredHosts,
      hosts,
      importFile,
      isFetchingHosts,
      isLoading,
      isMasked,
      isMaximized,
      isRendering,
      isSearchingHosts,
      isSelectOpen,
      keyBinding,
      mode,
      onHostSearch,
      onHostSelectToggle,
      onSearchClear,
      previewResult,
      previewTemplate,
      readOnly,
      renderedEditorValue,
      revertChanges,
      searchQuery,
      selectedHost,
      selectedView,
      showError,
      theme,
      toggleMaskValue,
      toggleModal,
      toggleRenderView,
      value,
      templateKindId,
    } = this.props;

    const editorViewProps = {
      value: isRendering ? previewResult : value,
      mode: isRendering ? 'Text' : mode,
      theme,
      keyBinding,
      onChange: isRendering ? noop : changeEditorValue,
      readOnly: readOnly || isRendering,
      isMasked,
    };
    const editorNameTab = {
      input: `${editorName}Code`,
      preview: `${editorName}Preview`,
    };

    return (
      <div id="editor-container">
        <ToastNotification
          id="preview_error_toast"
          type="error"
          className={showError ? '' : 'hidden'}
          onDismiss={() => dismissErrorToast()}
        >
          {errorText}
        </ToastNotification>
        <EditorNavbar
          changeDiffViewType={changeDiffViewType}
          changeTab={changeTab}
          changeSetting={changeSetting}
          modes={EDITOR_MODES}
          themes={EDITOR_THEMES}
          keyBindings={EDITOR_KEYBINDINGS}
          mode={isRendering ? 'Text' : mode}
          theme={theme}
          keyBinding={keyBinding}
          value={value}
          templateKindId={templateKindId}
          renderedEditorValue={renderedEditorValue}
          diffViewType={diffViewType}
          template={template}
          selectedView={selectedView}
          isDiff={template ? value !== template : false}
          isMasked={isMasked}
          isRendering={isRendering}
          isLoading={isLoading}
          isFetchingHosts={isFetchingHosts}
          isSearchingHosts={isSearchingHosts}
          importFile={importFile}
          showImport={showImport}
          showPreview={showPreview}
          showHostSelector={showHostSelector}
          showHide={showHide}
          revertChanges={revertChanges}
          previewTemplate={previewTemplate}
          hosts={hosts}
          filteredHosts={filteredHosts}
          selectedHost={selectedHost}
          isSafemodeEnabled={isSafemodeEnabled}
          renderPath={renderPath}
          safemodeRenderPath={safemodeRenderPath}
          toggleMaskValue={toggleMaskValue}
          toggleRenderView={toggleRenderView}
          toggleModal={toggleModal}
          previewResult={previewResult}
          searchQuery={searchQuery}
          onHostSelectToggle={onHostSelectToggle}
          onHostSearch={onHostSearch}
          onSearchClear={onSearchClear}
          isSelectOpen={isSelectOpen}
          showError={showError}
          fetchAndPreview={fetchAndPreview}
        />
        <EditorView
          {...editorViewProps}
          key="editorPreview"
          name={editorNameTab.preview}
          isSelected={selectedView === 'preview'}
          className="ace_editor_form ace_preview"
        />
        <EditorView
          {...editorViewProps}
          key="editorCode"
          name={editorNameTab.input}
          isSelected={selectedView === 'input'}
          className="ace_editor_form ace_input"
        />
        <div
          id="diff-table"
          className={selectedView === 'diff' ? '' : 'hidden'}
        >
          <DiffView
            oldText={template || ''}
            newText={value}
            viewType={diffViewType}
          />
        </div>
        <EditorModal
          key="editorModal"
          changeEditorValue={changeEditorValue}
          changeDiffViewType={changeDiffViewType}
          name={editorName}
          title={title}
          toggleModal={toggleModal}
          diffViewType={diffViewType}
          mode={mode}
          theme={theme}
          keyBinding={keyBinding}
          readOnly={readOnly}
          isMaximized={isMaximized}
          template={template || ''}
          editorValue={value}
          previewValue={previewResult}
          selectedView={selectedView}
          isMasked={isMasked}
          isRendering={isRendering}
        />
        {!readOnly && (
          <textarea className="hidden" name={name} value={value} readOnly />
        )}
      </div>
    );
  }
}

Editor.propTypes = {
  data: PropTypes.shape({
    showHide: PropTypes.bool,
    showImport: PropTypes.bool,
    showPreview: PropTypes.bool,
    showHostSelector: PropTypes.bool,
    template: PropTypes.string,
    templateClass: PropTypes.string,
    name: PropTypes.string,
    title: PropTypes.string,
    isSafemodeEnabled: PropTypes.bool,
    renderPath: PropTypes.string,
    safemodeRenderPath: PropTypes.string,
    hosts: PropTypes.array,
    locked: PropTypes.bool,
    type: PropTypes.string,
  }).isRequired,
  selectedHost: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  changeDiffViewType: PropTypes.func.isRequired,
  changeEditorValue: PropTypes.func.isRequired,
  changeSetting: PropTypes.func.isRequired,
  changeTab: PropTypes.func.isRequired,
  diffViewType: PropTypes.string.isRequired,
  dismissErrorToast: PropTypes.func.isRequired,
  editorName: PropTypes.string.isRequired,
  errorText: PropTypes.string.isRequired,
  hosts: PropTypes.array.isRequired,
  filteredHosts: PropTypes.array.isRequired,
  importFile: PropTypes.func.isRequired,
  initializeEditor: PropTypes.func.isRequired,
  isMasked: PropTypes.bool.isRequired,
  isMaximized: PropTypes.bool.isRequired,
  isRendering: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isFetchingHosts: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  mode: PropTypes.string.isRequired,
  previewTemplate: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
  previewResult: PropTypes.string.isRequired,
  revertChanges: PropTypes.func.isRequired,
  selectedView: PropTypes.string.isRequired,
  showError: PropTypes.bool.isRequired,
  theme: PropTypes.string.isRequired,
  toggleMaskValue: PropTypes.func.isRequired,
  toggleModal: PropTypes.func.isRequired,
  toggleRenderView: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  templateKindId: PropTypes.string,
  renderedEditorValue: PropTypes.string.isRequired,
  isSelectOpen: PropTypes.bool.isRequired,
  searchQuery: PropTypes.string.isRequired,
  onHostSelectToggle: PropTypes.func.isRequired,
  onHostSearch: PropTypes.func.isRequired,
  onSearchClear: PropTypes.func.isRequired,
  isSearchingHosts: PropTypes.bool.isRequired,
  fetchAndPreview: PropTypes.func.isRequired,
};

Editor.defaultProps = {
  templateKindId: '',
};

export default Editor;
