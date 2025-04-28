import React from 'react';
import { Modal, Title } from '@patternfly/react-core';
import PropTypes from 'prop-types';

import EditorView from './EditorView';
import DiffToggle from '../../DiffView/DiffToggle';
import DiffView from '../../DiffView/DiffView';

const EditorModal = ({
  changeDiffViewType,
  changeEditorValue,
  diffViewType,
  editorValue,
  previewValue,
  isMasked,
  isMaximized,
  isRendering,
  keyBinding,
  mode,
  name,
  readOnly,
  selectedView,
  template,
  theme,
  autocompletion,
  liveAutocompletion,
  title,
  toggleModal,
}) => {
  const header = (
    <div className={`${selectedView} ${theme.toLowerCase()}`}>
      <Title headingLevel="h4" id="editor-modal-h4" ouiaId="editor-modal-title">
        {title}
      </Title>
      {selectedView === 'diff' && (
        <DiffToggle
          stateView={diffViewType}
          changeState={viewType => changeDiffViewType(viewType)}
        />
      )}
    </div>
  );
  return (
    <Modal
      position="top"
      aria-labelledby="editor-modal-h4"
      ouiaId="editor-modal-component"
      id="editor-modal"
      className={`${selectedView} ${theme.toLowerCase()} editor-modal`}
      variant="primary"
      isOpen={isMaximized}
      onClose={toggleModal}
      header={header}
    >
      {selectedView === 'diff' ? (
        <div id="diff-table">
          <DiffView
            oldText={template}
            newText={editorValue}
            viewType={diffViewType}
          />
        </div>
      ) : (
        <EditorView
          value={isRendering ? previewValue : editorValue}
          name={name}
          mode={isRendering ? 'text' : mode}
          theme={theme}
          keyBinding={keyBinding}
          onChange={changeEditorValue}
          readOnly={readOnly || selectedView === 'preview'}
          className="editor ace_editor_modal"
          isMasked={isMasked}
          autocompletion={autocompletion}
          liveAutocompletion={liveAutocompletion}
        />
      )}
    </Modal>
  );
};

EditorModal.propTypes = {
  changeDiffViewType: PropTypes.func.isRequired,
  changeEditorValue: PropTypes.func.isRequired,
  diffViewType: PropTypes.string.isRequired,
  editorValue: PropTypes.string.isRequired,
  previewValue: PropTypes.string.isRequired,
  isRendering: PropTypes.bool.isRequired,
  isMasked: PropTypes.bool.isRequired,
  isMaximized: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  mode: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  readOnly: PropTypes.bool.isRequired,
  selectedView: PropTypes.string.isRequired,
  template: PropTypes.string.isRequired,
  theme: PropTypes.string.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
  title: PropTypes.string,
  toggleModal: PropTypes.func.isRequired,
};

EditorModal.defaultProps = {
  title: '',
};

export default EditorModal;
