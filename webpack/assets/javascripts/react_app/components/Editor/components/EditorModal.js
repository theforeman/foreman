import React from 'react';
import { Modal, Icon, Button } from 'patternfly-react';
import PropTypes from 'prop-types';

import EditorView from './EditorView';
import DiffRadioButtons from '../../DiffView/DiffRadioButtons';
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
}) => (
  <Modal show={isMaximized} onHide={toggleModal} className="editor-modal">
    <Modal.Header className={`${selectedView} ${theme.toLowerCase()}`}>
      <h4 id="editor-modal-h4">{title}</h4>
      <Button
        className="close"
        onClick={toggleModal}
        aria-hidden="true"
        aria-label="Close"
        bsStyle="link"
      >
        <Icon type="pf" name="close" />
      </Button>
      {selectedView === 'diff' && (
        <DiffRadioButtons
          stateView={diffViewType}
          changeState={viewType => changeDiffViewType(viewType)}
        />
      )}
    </Modal.Header>
    <Modal.Body className={selectedView}>
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
    </Modal.Body>
  </Modal>
);

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
