import React from 'react';
import PropTypes from 'prop-types';
import { Alert, Button } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { EDITOR_TAB_NAMES } from '../EditorConstants';

const EditorAlert = ({
  showPreview,
  selectedView,
  previewResult,
  renderedEditorValue,
  value,
  onClick,
}) =>
  showPreview &&
  selectedView === EDITOR_TAB_NAMES.preview &&
  previewResult !== '' &&
  renderedEditorValue !== value ? (
    <div key="preview-alert" id="outdated-preview-alert">
      <Alert
        ouiaId="outdated-preview-alert"
        variant="warning"
        title={
          <>
            {__('Preview is outdated.')}
            <Button ouiaId="preview-button" variant="link" onClick={onClick}>
              {__('Preview')}
            </Button>
          </>
        }
      />
    </div>
  ) : null;

EditorAlert.propTypes = {
  showPreview: PropTypes.bool.isRequired,
  selectedView: PropTypes.string.isRequired,
  previewResult: PropTypes.string.isRequired,
  renderedEditorValue: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
};

export default EditorAlert;
