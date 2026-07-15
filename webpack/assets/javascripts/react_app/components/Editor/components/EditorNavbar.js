/* eslint-disable max-lines */
import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { Spinner, Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import AutocompleteInput from '../../common/AutocompleteInput/AutocompleteInput';
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
  onHostSearch,
  fetchAndPreview,
  safemode,
  selectedRenderPath,
  handleSafeModeChange,
}) => {
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

  const handleTabSelect = (event, tabKey) => {
    if (tabKey === selectedView) {
      return;
    }

    if (tabKey === 'input') {
      if (isRendering) toggleRenderView();
      changeTab('input');
      return;
    }

    if (tabKey === 'diff') {
      changeTab('diff');
      return;
    }

    if (tabKey === 'preview') {
      if (!isRendering) toggleRenderView();
      changeTab('preview');
      if (selectedHost.id === '') {
        fetchAndPreview(selectedRenderPath, templateKindId, !showHostSelector);
      }
    }
  };

  return (
    <div className="navbar navbar-form navbar-full-width navbar-editor">
      <div className="editor-navbar-tabs-row">
        <Tabs
          activeKey={selectedView}
          onSelect={handleTabSelect}
          ouiaId="editor-navbar-tabs"
        >
          <Tab
            eventKey="input"
            title={<TabTitleText>{__('Editor')}</TabTitleText>}
            id="input-navitem"
            ouiaId="input-navitem"
          />
          <Tab
            eventKey="diff"
            title={<TabTitleText>{__('Changes')}</TabTitleText>}
            isDisabled={!isDiff}
            id="diff-navitem"
            ouiaId="diff-navitem"
          />
          {showPreview && (
            <Tab
              eventKey="preview"
              title={<TabTitleText>{__('Preview')}</TabTitleText>}
              id="preview-navitem"
              ouiaId="preview-navitem"
            />
          )}
        </Tabs>
        {showPreview && (
          <>
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
                  allowClear={false}
                />
                {isFetchingHosts && (
                  <Spinner size="sm" aria-label={__('Loading')} isInline />
                )}
              </>
            )}
            <EditorSafemodeCheckbox
              show={selectedView === 'preview'}
              checked={safemode}
              disabled={isSafemodeEnabled}
              handleSafeModeChange={handleSafeModeChange}
            />
            {isLoading && (
              <Spinner size="sm" aria-label={__('Loading')} isInline />
            )}
          </>
        )}
      </div>
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
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  onHostSearch: PropTypes.func.isRequired,
  previewTemplate: PropTypes.func.isRequired,
  safemode: PropTypes.bool.isRequired,
  selectedRenderPath: PropTypes.string.isRequired,
  handleSafeModeChange: PropTypes.func.isRequired,
  isSafemodeEnabled: PropTypes.bool.isRequired,
  renderPath: PropTypes.string,
  revertChanges: PropTypes.func.isRequired,
  selectedHost: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  selectedView: PropTypes.string.isRequired,
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
  template: '',
  showHostSelector: true,
  templateKindId: '',
};

export default EditorNavbar;
