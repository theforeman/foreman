import React, { useState, useContext } from 'react';
import PropTypes from 'prop-types';
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Spinner,
  Button,
  Alert,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import EditorTabs from './EditorTabs';
import EditorOptions from './EditorOptions';
import EditorHostSelect from './EditorHostSelect';
import EditorSafemodeCheckbox from './EditorSafemodeCheckbox';
import { EditorContext } from '../EditorContext';
import { PREVIEW, ALIGN_LEFT, ALIGN_RIGHT } from '../EditorConstants';

const EditorToolbar = props => {
  const {
    hosts,
    filteredHosts,
    isLoading,
    isFetchingHosts,
    isSearchingHosts,
    previewTemplate,
    isSafemodeEnabled,
    renderPath,
    safemodeRenderPath,
    selectedHost,
    showHostSelector,
    value,
    templateKindId,
    renderedEditorValue,
    previewResult,
    onHostSelectToggle,
    onHostSearch,
    isSelectOpen,
  } = props;

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

  const { selectedView } = useContext(EditorContext);

  return (
    <Toolbar className="bottom-cling-toolbar">
      <ToolbarContent>
        <ToolbarItem
          id="toolbar-item-toolbar-tabs"
          alignment={{ default: ALIGN_LEFT }}
          key="toolbar-item-editor-tabs"
        >
          <EditorTabs {...props} selectedRenderPath={selectedRenderPath} />
        </ToolbarItem>

        {showHostSelector && (
          <ToolbarItem
            id="toolbar-item-show-host-selector"
            alignment={{ default: ALIGN_LEFT }}
            key="toolbar-item-show-host-selector"
          >
            <EditorHostSelect
              {...props}
              show={selectedView === PREVIEW}
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
              onToggle={onHostSelectToggle}
              onSearchChange={onHostSearch}
              options={isSearchingHosts ? filteredHosts : hosts}
            />
          </ToolbarItem>
        )}

        <ToolbarItem
          id="toolbar-item-editor-safemode-checkbox"
          alignment={{ default: ALIGN_LEFT }}
          key="toolbar-item-editor-safemode-checkbox"
        >
          <EditorSafemodeCheckbox
            show={selectedView === PREVIEW}
            checked={safemode}
            disabled={isSafemodeEnabled}
            handleSafeModeChange={handleSafeModeChange}
          />
        </ToolbarItem>

        {selectedView === PREVIEW &&
          previewResult !== '' &&
          renderedEditorValue !== value && (
            <ToolbarItem
              id="toolbar-item-outdated-preview-alert"
              alignment={{ default: ALIGN_LEFT }}
              key="toolbar-item-outdated-preview-alert"
            >
              <Alert type="warning">
                {__('Preview is outdated.')}
                <Button
                  variant="link"
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
            </ToolbarItem>
          )}

        {isLoading && (
          <ToolbarItem
            id="toolbar-item-preview-spinner"
            alignment={{ default: ALIGN_LEFT }}
            key="toolbar-item-preview-spinner"
          >
            <Spinner size="sm" isSVG />
          </ToolbarItem>
        )}

        <ToolbarItem
          id="toolbar-item-editor-options"
          alignment={{ default: ALIGN_RIGHT }}
          key="toolbar-item-editor-options"
        >
          <EditorOptions {...props} />
        </ToolbarItem>
      </ToolbarContent>
    </Toolbar>
  );
};

EditorToolbar.propTypes = {
  filteredHosts: PropTypes.array,
  hosts: PropTypes.array,
  isFetchingHosts: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isSearchingHosts: PropTypes.bool.isRequired,
  isSelectOpen: PropTypes.bool.isRequired,
  onHostSearch: PropTypes.func.isRequired,
  onHostSelectToggle: PropTypes.func.isRequired,
  previewResult: PropTypes.string.isRequired,
  previewTemplate: PropTypes.func.isRequired,
  renderedEditorValue: PropTypes.string.isRequired,
  isSafemodeEnabled: PropTypes.bool.isRequired,
  renderPath: PropTypes.string,
  safemodeRenderPath: PropTypes.string,
  selectedHost: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  showHostSelector: PropTypes.bool,
  value: PropTypes.string.isRequired,
  templateKindId: PropTypes.string,
};

EditorToolbar.defaultProps = {
  hosts: [],
  filteredHosts: [],
  renderPath: '',
  safemodeRenderPath: '',
  showHostSelector: true,
  templateKindId: '',
};

export default EditorToolbar;
