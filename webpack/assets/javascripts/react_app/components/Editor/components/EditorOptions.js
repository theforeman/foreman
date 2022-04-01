/* eslint-disable no-alert */
import React from 'react';
import PropTypes from 'prop-types';

import { Button, Icon, FormControl } from 'patternfly-react';

import { Tooltip, TooltipPosition } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { bindMethods } from '../../../common/helpers';
import DiffRadioButtons from '../../DiffView/DiffRadioButtons';
import EditorSettings from './EditorSettings';

class EditorOptions extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['fileDialog']);
    this.fileInput = React.createRef();
  }

  fileDialog() {
    this.fileInput.click();
  }

  render() {
    const {
      changeDiffViewType,
      changeSetting,
      changeTab,
      diffViewType,
      importFile,
      isDiff,
      isMasked,
      keyBinding,
      keyBindings,
      mode,
      modes,
      revertChanges,
      selectedView,
      showHide,
      showImport,
      template,
      theme,
      themes,
      autocompletion,
      liveAutocompletion,
      toggleMaskValue,
      toggleModal,
    } = this.props;

    return (
      <div id="editor-dropdowns">
        {selectedView === 'diff' && (
          <DiffRadioButtons
            stateView={diffViewType}
            changeState={viewType => changeDiffViewType(viewType)}
          />
        )}

        <h4 id="divider">|</h4>
        {showHide && (
          <Tooltip content={__('Hide Content')} position={TooltipPosition.top}>
            <Button
              disabled={selectedView !== 'input'}
              className="editor-button"
              id="hide-btn"
              onClick={() => toggleMaskValue(isMasked)}
              bsStyle="link"
            >
              <Icon size="lg" type="fa" name={isMasked ? 'eye' : 'eye-slash'} />
            </Button>
          </Tooltip>
        )}
        {isDiff ? ( // fixing tooltip showing sometimes for disabled icon
          <Tooltip
            content={__('Revert Local Changes')}
            position={TooltipPosition.top}
          >
            <Button
              className="editor-button"
              id="undo-btn"
              onClick={() => {
                if (
                  window.confirm(
                    'Are you sure you would like to revert all changes?'
                  )
                ) {
                  revertChanges(template);
                  if (selectedView !== 'input') changeTab('input');
                }
              }}
              bsStyle="link"
            >
              <Icon size="2x" type="pf" name="restart" />
            </Button>
          </Tooltip>
        ) : (
          <Button
            disabled
            className="editor-button"
            id="undo-btn"
            bsStyle="link"
          >
            <Icon size="2x" type="pf" name="restart" />
          </Button>
        )}
        {showImport && (
          <Tooltip content={__('Import File')} position={TooltipPosition.top}>
            <Button
              disabled={selectedView !== 'input'}
              className="import-button"
              id="import-btn"
              bsStyle="link"
              onClick={() => this.fileDialog()}
            >
              <Icon size="lg" type="pf" name="folder-open" />
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
        )}
        <EditorSettings
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
        <Tooltip content={__('Maximize')} position={TooltipPosition.top}>
          <Button
            className="editor-button"
            id="fullscreen-btn"
            onClick={toggleModal}
            bsStyle="link"
          >
            <Icon size="lg" type="fa" name="arrows-alt" />
          </Button>
        </Tooltip>
      </div>
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
