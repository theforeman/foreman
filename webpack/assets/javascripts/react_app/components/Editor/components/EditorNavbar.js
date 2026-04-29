/* eslint-disable max-lines */
import React, { useMemo, useState } from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner, Alert, Button } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';
import AutocompleteInput from '../../common/AutocompleteInput/AutocompleteInput';
import EditorRadioButton from './EditorRadioButton';
import EditorOptions from './EditorOptions';
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
  showImport,
  showPreview,
  showHostSelector,
  template,
  theme,
  themes,
  autocompletion,
  liveAutocompletion,
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

  const hostOptions = useMemo(() => {
    const pool = isSearchingHosts ? filteredHosts : hosts;
    const mapped = Array.from(pool, h => ({
      value: h.id,
      label: h.name,
    }));
    if (selectedHost?.id !== '' && selectedHost?.id != null) {
      const idStr = String(selectedHost.id);
      if (!mapped.some(o => String(o.value) === idStr)) {
        return [
          { value: selectedHost.id, label: selectedHost.name },
          ...mapped,
        ];
      }
    }
    return mapped;
  }, [hosts, filteredHosts, selectedHost, isSearchingHosts]);

  const resolveHostById = hostId => {
    const strId = String(hostId);
    if (String(selectedHost.id) === strId) {
      previewTemplate({
        host: selectedHost,
        renderPath: selectedRenderPath,
        templateKindId,
      });
      return;
    }
    const primary = isSearchingHosts ? filteredHosts : hosts;
    let host = primary.find(h => String(h.id) === strId);
    if (!host) host = hosts.find(h => String(h.id) === strId);
    if (!host) host = filteredHosts.find(h => String(h.id) === strId);
    if (host) {
      previewTemplate({
        host,
        renderPath: selectedRenderPath,
        templateKindId,
      });
    }
  };

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
          <>
            <EditorRadioButton
              stateView={selectedView}
              btnView="preview"
              title={__('Preview')}
              onClick={() => {
                if (selectedView !== 'preview') {
                  if (!isRendering) toggleRenderView();
                  changeTab('preview');
                  if (selectedHost.id === '')
                    fetchAndPreview(
                      selectedRenderPath,
                      templateKindId,
                      !showHostSelector
                    );
                }
              }}
            />
            {showHostSelector && selectedView === 'preview' && (
              <>
                <AutocompleteInput
                  name="editor-preview-host"
                  placeholder={__('Filter Host...')}
                  selected={
                    selectedHost.id === '' || selectedHost.id == null
                      ? ''
                      : selectedHost.id
                  }
                  options={hostOptions}
                  onChange={inputValue =>
                    onHostSearch({ target: { value: inputValue } })
                  }
                  onBlur={() => onHostSearch({ target: { value: '' } })}
                  onSelect={resolveHostById}
                />
                {isFetchingHosts && (
                  <div id="editor-host-fetch-spinner">
                    <Spinner size="sm" loading />
                  </div>
                )}
              </>
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
                          templateKindId,
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
          </>
        )}
      </Nav>
      <EditorOptions
        hosts={hosts}
        value={value}
        renderPath={renderPath}
        showImport={showImport}
        showPreview={showPreview}
        showHostSelector={showHostSelector}
        isDiff={isDiff}
        diffViewType={diffViewType}
        isRendering={isRendering}
        importFile={importFile}
        template={template}
        revertChanges={revertChanges}
        changeDiffViewType={changeDiffViewType}
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
  showImport: PropTypes.bool.isRequired,
  showPreview: PropTypes.bool.isRequired,
  showHostSelector: PropTypes.bool,
  template: PropTypes.string,
  theme: PropTypes.string.isRequired,
  themes: PropTypes.array.isRequired,
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
  template: '',
  showHostSelector: true,
  templateKindId: '',
};

export default EditorNavbar;
