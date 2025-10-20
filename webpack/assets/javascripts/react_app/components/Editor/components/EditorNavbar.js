import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Tabs } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import EditorRadioButton from './EditorRadioButton';
import EditorOptions from './EditorOptions';
import EditorHostSelect from './EditorHostSelect';
import EditorSafemodeCheckbox from './EditorSafemodeCheckbox';
import EditorAlert from './EditorAlert';
import { EDITOR_TAB_NAMES } from '../EditorConstants';

const EditorNavbar = ({
  changeDiffViewType,
  changeSetting,
  changeTab,
  diffViewType,
  hosts,
  filteredHosts,
  importFile,
  isDiff,
  isLoading,
  isMasked,
  isRendering,
  isFetchingHosts,
  isSearchingHosts,
  keyBinding,
  keyBindings,
  mode,
  modes,
  previewTemplate,
  isSafemodeEnabled,
  renderPath,
  safemodeRenderPath,
  revertChanges,
  selectedHost,
  selectedView,
  showHide,
  showImport,
  showPreview,
  showHostSelector,
  template,
  theme,
  themes,
  autocompletion,
  liveAutocompletion,
  toggleMaskValue,
  toggleModal,
  toggleRenderView,
  value,
  templateKindId,
  renderedEditorValue,
  previewResult,
  searchQuery,
  onHostSelectToggle,
  onHostSearch,
  onSearchClear,
  isSelectOpen,
  showError,
  fetchAndPreview,
}) => {
  const [safemode, setSafemode] = useState(isSafemodeEnabled);
  const handleSafeModeChange = ({ currentTarget: { checked: newChecked } }) => {
    setSafemode(newChecked);
    const newRenderPath = newChecked ? safemodeRenderPath : renderPath;
    previewTemplate({
      host: selectedHost,
      renderPath: newRenderPath,
      templateKindId,
    });
  };
  const selectedRenderPath = safemode ? safemodeRenderPath : renderPath;
  const selectedTabsIndex = Object.values(EDITOR_TAB_NAMES).indexOf(
    selectedView
  );

  const renderTabsContent = () => {
    const tabs = [];

    tabs.push(
      <EditorRadioButton
        key="input"
        eventKey={0}
        stateView={selectedView}
        btnView="input"
        title={__('Editor')}
        onClick={() => {
          if (selectedView !== EDITOR_TAB_NAMES.input) {
            if (isRendering) toggleRenderView();
            changeTab(EDITOR_TAB_NAMES.input);
          }
        }}
      />
    );
    tabs.push(
      <EditorRadioButton
        key="diff"
        eventKey={1}
        stateView={selectedView}
        disabled={!isDiff}
        btnView="diff"
        title={__('Changes')}
        onClick={() => {
          if (selectedView !== EDITOR_TAB_NAMES.diff) {
            changeTab(EDITOR_TAB_NAMES.diff);
          }
        }}
      />
    );

    if (showPreview)
      tabs.push(
        <EditorRadioButton
          key="preview"
          eventKey={2}
          stateView={selectedView}
          btnView="preview"
          title={__('Preview')}
          onClick={() => {
            if (selectedView !== EDITOR_TAB_NAMES.preview) {
              if (!isRendering) toggleRenderView();
              changeTab(EDITOR_TAB_NAMES.preview);
              if (selectedHost.id === '')
                fetchAndPreview(
                  selectedRenderPath,
                  templateKindId,
                  !showHostSelector
                );
            }
          }}
        />
      );

    if (
      showPreview &&
      showHostSelector &&
      selectedView === EDITOR_TAB_NAMES.preview
    )
      tabs.push(
        <EditorHostSelect
          key="host-select"
          show
          open={isSelectOpen}
          selectedItem={selectedHost}
          placeholder={__('Select Host...')}
          isLoading={isFetchingHosts}
          onChange={host =>
            previewTemplate({
              host,
              renderPath: selectedRenderPath,
              templateKindId,
            })
          }
          searchQuery={searchQuery}
          onToggle={onHostSelectToggle}
          onSearchChange={onHostSearch}
          onSearchClear={onSearchClear}
          options={isSearchingHosts ? filteredHosts : hosts}
        />
      );

    if (showPreview)
      tabs.push(
        <EditorSafemodeCheckbox
          key="safe-mode"
          show={selectedView === EDITOR_TAB_NAMES.preview}
          checked={safemode}
          disabled={isSafemodeEnabled}
          handleSafeModeChange={handleSafeModeChange}
        />
      );

    tabs.push(
      <EditorAlert
        key="editor-alert"
        showPreview={showPreview}
        selectedView={selectedView}
        previewResult={previewResult}
        renderedEditorValue={renderedEditorValue}
        value={value}
        onClick={() =>
          previewTemplate({
            host: selectedHost,
            renderPath: selectedRenderPath,
            templateKindId,
          })
        }
      />
    );

    return tabs;
  };

  return (
    <div className="navbar navbar-form navbar-full-width navbar-editor">
      <Tabs
        ouiaId="editor-horizontal-navbar"
        aria-label="Editor Tabs"
        variant="horizontal"
        activeKey={selectedTabsIndex}
      >
        {renderTabsContent()}
        <EditorOptions
          key="options"
          hosts={hosts}
          value={value}
          renderPath={renderPath}
          showImport={showImport}
          showHide={showHide}
          showPreview={showPreview}
          showHostSelector={showHostSelector}
          isDiff={isDiff}
          diffViewType={diffViewType}
          isMasked={isMasked}
          isRendering={isRendering}
          importFile={importFile}
          template={template}
          revertChanges={revertChanges}
          changeDiffViewType={changeDiffViewType}
          toggleMaskValue={toggleMaskValue}
          changeSetting={changeSetting}
          changeTab={changeTab}
          toggleModal={toggleModal}
          selectedView={selectedView}
          mode={mode}
          modes={modes}
          keyBinding={keyBinding}
          keyBindings={keyBindings}
          theme={theme}
          themes={themes}
          autocompletion={autocompletion}
          liveAutocompletion={liveAutocompletion}
        />
      </Tabs>
    </div>
  );
};

EditorNavbar.propTypes = {
  changeDiffViewType: PropTypes.func.isRequired,
  changeSetting: PropTypes.func.isRequired,
  changeTab: PropTypes.func.isRequired,
  diffViewType: PropTypes.string.isRequired,
  fetchAndPreview: PropTypes.func.isRequired,
  filteredHosts: PropTypes.array,
  hosts: PropTypes.array,
  importFile: PropTypes.func.isRequired,
  isDiff: PropTypes.bool.isRequired,
  isFetchingHosts: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isMasked: PropTypes.bool.isRequired,
  isRendering: PropTypes.bool.isRequired,
  isSearchingHosts: PropTypes.bool.isRequired,
  isSelectOpen: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  onHostSearch: PropTypes.func.isRequired,
  onHostSelectToggle: PropTypes.func.isRequired,
  onSearchClear: PropTypes.func.isRequired,
  previewResult: PropTypes.string.isRequired,
  previewTemplate: PropTypes.func.isRequired,
  renderedEditorValue: PropTypes.string.isRequired,
  isSafemodeEnabled: PropTypes.bool.isRequired,
  renderPath: PropTypes.string,
  safemodeRenderPath: PropTypes.string,
  revertChanges: PropTypes.func.isRequired,
  searchQuery: PropTypes.string.isRequired,
  selectedHost: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  selectedView: PropTypes.string.isRequired,
  showError: PropTypes.bool.isRequired,
  showHide: PropTypes.bool,
  showImport: PropTypes.bool.isRequired,
  showPreview: PropTypes.bool.isRequired,
  showHostSelector: PropTypes.bool,
  template: PropTypes.string,
  theme: PropTypes.string.isRequired,
  themes: PropTypes.array.isRequired,
  toggleMaskValue: PropTypes.func.isRequired,
  toggleModal: PropTypes.func.isRequired,
  toggleRenderView: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  templateKindId: PropTypes.string,
};

EditorNavbar.defaultProps = {
  hosts: [],
  filteredHosts: [],
  renderPath: '',
  safemodeRenderPath: '',
  showHide: false,
  template: '',
  showHostSelector: true,
  templateKindId: '',
};

export default EditorNavbar;
