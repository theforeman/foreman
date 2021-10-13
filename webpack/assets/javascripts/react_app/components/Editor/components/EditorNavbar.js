import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner, Alert, Button } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';
import EditorRadioButton from './EditorRadioButton';
import EditorOptions from './EditorOptions';
import EditorHostSelect from './EditorHostSelect';
import EditorSafemodeCheckbox from './EditorSafemodeCheckbox';

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
  toggleMaskValue,
  toggleModal,
  toggleRenderView,
  value,
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
    previewTemplate({ host: selectedHost, renderPath: newRenderPath });
  };
  const selectedRenderPath = safemode ? safemodeRenderPath : renderPath;

  return (
    <div className="navbar navbar-form navbar-full-width navbar-editor">
      <Nav className="nav nav-tabs nav-tabs-pf nav-tabs-pf-secondary">
        <EditorRadioButton
          stateView={selectedView}
          btnView="input"
          title={__('Editor')}
          onClick={() => {
            if (selectedView !== 'input') {
              if (isRendering) toggleRenderView();
              changeTab('input');
            }
          }}
        />
        <EditorRadioButton
          stateView={selectedView}
          disabled={!isDiff}
          btnView="diff"
          title={__('Changes')}
          onClick={() => {
            if (selectedView !== 'diff') {
              changeTab('diff');
            }
          }}
        />
        {showPreview && (
          <React.Fragment>
            <EditorRadioButton
              stateView={selectedView}
              btnView="preview"
              title={__('Preview')}
              onClick={() => {
                if (selectedView !== 'preview') {
                  if (!isRendering) toggleRenderView();
                  changeTab('preview');
                  if (selectedHost.id === '')
                    fetchAndPreview(selectedRenderPath);
                }
              }}
            />
            {showHostSelector && (
              <EditorHostSelect
                show={selectedView === 'preview'}
                open={isSelectOpen}
                selectedItem={selectedHost}
                placeholder={__('Select Host...')}
                isLoading={isFetchingHosts}
                onChange={(host) =>
                  previewTemplate({ host, renderPath: selectedRenderPath })
                }
                searchQuery={searchQuery}
                onToggle={onHostSelectToggle}
                onSearchChange={onHostSearch}
                onSearchClear={onSearchClear}
                options={isSearchingHosts ? filteredHosts : hosts}
                key="hostsSelect"
              />
            )}
            <EditorSafemodeCheckbox
              show={selectedView === 'preview'}
              checked={safemode}
              disabled={isSafemodeEnabled}
              handleSafeModeChange={handleSafeModeChange}
            />
            {selectedView === 'preview' &&
              previewResult !== '' &&
              renderedEditorValue !== value && (
                <div id="outdated-preview-alert">
                  <Alert type="warning">
                    {__('Preview is outdated.')}
                    <Button
                      bsStyle="link"
                      onClick={() =>
                        previewTemplate({
                          host: selectedHost,
                          renderPath: selectedRenderPath,
                        })
                      }
                    >
                      {__('Preview')}
                    </Button>
                  </Alert>
                </div>
              )}
            {isLoading && (
              <div id="preview-spinner">
                <Spinner size="sm" loading />
              </div>
            )}
          </React.Fragment>
        )}
      </Nav>
      <EditorOptions
        hosts={hosts}
        value={value}
        renderPath={renderPath}
        previewTemplate={previewTemplate}
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
      />
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
};

EditorNavbar.defaultProps = {
  hosts: [],
  filteredHosts: [],
  renderPath: '',
  safemodeRenderPath: '',
  showHide: false,
  template: '',
  showHostSelector: true,
};

export default EditorNavbar;
