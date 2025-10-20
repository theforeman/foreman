/* eslint-disable no-alert */
import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';
import { Button, Icon, Tooltip, TooltipPosition } from '@patternfly/react-core';
import {
  ArrowsAltIcon,
  EyeIcon,
  EyeSlashIcon,
  UndoIcon,
  UploadIcon,
} from '@patternfly/react-icons';

import { translate as __ } from '../../../common/I18n';
import { bindMethods } from '../../../common/helpers';
import DiffToggle from '../../DiffView/DiffToggle';
import EditorSettings from './EditorSettings';
import { EDITOR_TAB_NAMES } from '../EditorConstants';

class EditorOptions extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['fileDialog']);
    this.fileInput = React.createRef();
  }

  fileDialog() {
    this.fileInput.click();
  }

  renderOptionButtons() {
    const {
      changeTab,
      importFile,
      isDiff,
      isMasked,
      revertChanges,
      selectedView,
      showHide,
      showImport,
      template,
      toggleMaskValue,
    } = this.props;

    const buttons = [];

    if (showHide) {
      buttons.push(
        <Tooltip
          key="hide-content-tooltip"
          content={__('Hide Content')}
          position={TooltipPosition.top}
        >
          <Button
            ouiaId="hide-content-button"
            isDisabled={selectedView !== EDITOR_TAB_NAMES.input}
            className="editor-button"
            id="hide-btn"
            onClick={() => toggleMaskValue(isMasked)}
            variant="link"
          >
            <Icon size="md">{isMasked ? <EyeIcon /> : <EyeSlashIcon />}</Icon>
          </Button>
        </Tooltip>
      );
    }

    const revertButton = (
      <Tooltip
        key="revert-changes-tooltip"
        content={__('Revert Local Changes')}
        position={TooltipPosition.top}
      >
        <Button
          ouiaId="revert-local-changes-button"
          className="editor-button"
          id="undo-btn"
          onClick={() => {
            if (
              window.confirm(
                'Are you sure you would like to revert all changes?'
              )
            ) {
              revertChanges(template);
              if (selectedView !== EDITOR_TAB_NAMES.input) {
                changeTab(EDITOR_TAB_NAMES.input);
              }
            }
          }}
          isDisabled={!isDiff}
          variant="link"
        >
          <Icon size="md">
            <UndoIcon />
          </Icon>
        </Button>
      </Tooltip>
    );

    buttons.push(revertButton);

    if (showImport) {
      buttons.push(
        <Tooltip
          key="import-file-tooltip"
          content={__('Import File')}
          position={TooltipPosition.top}
        >
          <Button
            ouiaId="import-file-button"
            isDisabled={selectedView !== EDITOR_TAB_NAMES.input}
            className="import-button"
            id="import-btn"
            variant="link"
            onClick={() => this.fileDialog()}
          >
            <Icon size="md">
              <UploadIcon />
            </Icon>
            <FormControl
              inputRef={ref => {
                this.fileInput = ref;
              }}
              className="hidden"
              type="file"
              onChange={importFile}
            />
          </Button>
        </Tooltip>
      );
    }

    return buttons;
  }

  render() {
    const {
      changeDiffViewType,
      changeSetting,
      diffViewType,
      keyBinding,
      keyBindings,
      mode,
      modes,
      selectedView,
      theme,
      themes,
      autocompletion,
      liveAutocompletion,
      toggleModal,
    } = this.props;

    return (
      <>
        <li key="diff-toggle" className="middle">
          {selectedView === EDITOR_TAB_NAMES.diff && (
            <DiffToggle
              stateView={diffViewType}
              changeState={viewType => changeDiffViewType(viewType)}
            />
          )}
        </li>
        <li key="divider" className="divider" />
        <li key="editor-options" id="editor-options">
          {this.renderOptionButtons()}
          <EditorSettings
            key="editor-settings"
            changeSetting={changeSetting}
            selectedView={selectedView}
            modes={modes}
            mode={mode}
            keyBindings={keyBindings}
            keyBinding={keyBinding}
            theme={theme}
            themes={themes}
            autocompletion={autocompletion}
            liveAutocompletion={liveAutocompletion}
          />
          <Tooltip
            key="maximize-editor-tooltip"
            content={__('Maximize')}
            position={TooltipPosition.top}
          >
            <Button
              ouiaId="maximize-editor-button"
              className="editor-button"
              id="fullscreen-btn"
              onClick={toggleModal}
              variant="link"
            >
              <Icon size="md">
                <ArrowsAltIcon />
              </Icon>
            </Button>
          </Tooltip>
        </li>
      </>
    );
  }
}

EditorOptions.propTypes = {
  changeDiffViewType: PropTypes.func.isRequired,
  changeSetting: PropTypes.func.isRequired,
  changeTab: PropTypes.func.isRequired,
  diffViewType: PropTypes.string.isRequired,
  importFile: PropTypes.func.isRequired,
  isDiff: PropTypes.bool.isRequired,
  isMasked: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  revertChanges: PropTypes.func.isRequired,
  selectedView: PropTypes.string.isRequired,
  showHide: PropTypes.bool,
  showImport: PropTypes.bool.isRequired,
  template: PropTypes.string,
  theme: PropTypes.string.isRequired,
  themes: PropTypes.array.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
  toggleMaskValue: PropTypes.func.isRequired,
  toggleModal: PropTypes.func.isRequired,
};

EditorOptions.defaultProps = {
  showHide: false,
  template: '',
};

export default EditorOptions;
