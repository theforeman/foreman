/* eslint-disable no-alert */
import React, { useRef, useContext } from 'react';
import PropTypes from 'prop-types';

import { Button, Icon, FormControl } from 'patternfly-react';

import {
  Tooltip,
  TooltipPosition,
  Flex,
  FlexItem,
  Divider,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import DiffToggle from '../../DiffView/DiffToggle';
import EditorSettings from './EditorSettings';
import { INPUT, DIFF } from '../EditorConstants';
import { EditorContext } from '../EditorContext';

const EditorOptions = props => {
  const {
    changeDiffViewType,
    changeSetting,
    diffViewType,
    importFile,
    isDiff,
    isMasked,
    keyBinding,
    keyBindings,
    mode,
    modes,
    revertChanges,
    showHide,
    showImport,
    template,
    theme,
    themes,
    autocompletion,
    liveAutocompletion,
    toggleMaskValue,
    toggleModal,
  } = props;

  const fileInput = useRef('');

  const openFileDialog = () => {
    fileInput.current.click();
  };

  const { selectedView, setSelectedView } = useContext(EditorContext);

  return (
    <Flex id="editor-dropdowns" spaceItems={{ default: 'spaceItemsNone' }}>
      {selectedView === DIFF && (
        <>
          <FlexItem>
            <DiffToggle
              stateView={diffViewType}
              changeState={viewType => changeDiffViewType(viewType)}
            />
          </FlexItem>
          <FlexItem spacer={{ default: 'spacerMd' }} />
          <Divider
            orientation={{ default: 'vertical' }}
            inset={{ default: 'insetMd' }}
          />
        </>
      )}

      {showHide && (
        <FlexItem>
          <Tooltip content={__('Hide Content')} position={TooltipPosition.top}>
            <Button
              disabled={selectedView !== INPUT}
              className="editor-button"
              id="hide-btn"
              onClick={() => toggleMaskValue(isMasked)}
              bsStyle="link"
            >
              <Icon size="lg" type="fa" name={isMasked ? 'eye' : 'eye-slash'} />
            </Button>
          </Tooltip>
        </FlexItem>
      )}
      {isDiff ? ( // fixing tooltip showing sometimes for disabled icon
        <FlexItem>
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
                  if (selectedView !== INPUT) {
                    setSelectedView(INPUT);
                  }
                }
              }}
              bsStyle="link"
            >
              <Icon size="2x" type="pf" name="restart" />
            </Button>
          </Tooltip>
        </FlexItem>
      ) : (
        <FlexItem>
          <Button
            disabled
            className="editor-button"
            id="undo-btn"
            bsStyle="link"
          >
            <Icon size="2x" type="pf" name="restart" />
          </Button>
        </FlexItem>
      )}
      {showImport && (
        <FlexItem>
          <Tooltip content={__('Import File')} position={TooltipPosition.top}>
            <Button
              disabled={selectedView !== INPUT}
              className="import-button"
              id="import-btn"
              bsStyle="link"
              onClick={openFileDialog}
            >
              <Icon size="lg" type="pf" name="folder-open" />
              <FormControl
                inputRef={ref => {
                  fileInput.current = ref;
                }}
                className="hidden"
                type="file"
                onChange={importFile}
              />
            </Button>
          </Tooltip>
        </FlexItem>
      )}
      <FlexItem>
        <div role="option" aria-selected>
          <EditorSettings
            changeSetting={changeSetting}
            modes={modes}
            mode={mode}
            keyBindings={keyBindings}
            keyBinding={keyBinding}
            theme={theme}
            themes={themes}
            autocompletion={autocompletion}
            liveAutocompletion={liveAutocompletion}
          />
        </div>
      </FlexItem>
      <FlexItem>
        <Tooltip content={__('Maximize')} position={TooltipPosition.top}>
          <Button
            className="editor-button"
            id="fullscreen-btn"
            onClick={toggleModal}
            bsStyle="link"
            aria-label="Open Modal"
          >
            <Icon size="lg" type="fa" name="arrows-alt" />
          </Button>
        </Tooltip>
      </FlexItem>
    </Flex>
  );
};

EditorOptions.propTypes = {
  changeDiffViewType: PropTypes.func.isRequired,
  changeSetting: PropTypes.func.isRequired,
  diffViewType: PropTypes.string.isRequired,
  importFile: PropTypes.func.isRequired,
  isDiff: PropTypes.bool.isRequired,
  isMasked: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  revertChanges: PropTypes.func.isRequired,
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
