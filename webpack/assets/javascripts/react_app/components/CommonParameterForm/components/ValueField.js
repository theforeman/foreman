import React, { useState } from 'react';
import { Modal } from 'patternfly-react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import FormField from '../../common/forms/FormField';

import {
  fieldSizeByType,
  valueFieldByType,
  showFullScreenBtn,
} from '../CommonParamFormHelpers';

const ValueField = ({ value, selectedType, isMasked, onChange, error }) => {
  const [showModal, setShowModal] = useState(false);
  const valueFieldProps = {
    id: 'common_parameter_value',
    name: 'common_parameter[value]',
    css: 'form-control',
    value,
    onChange,
    isMasked,
  };

  return (
    <React.Fragment>
      <FormField
        label={__('Value')}
        inputSizeClass={fieldSizeByType(selectedType)}
        error={error}
      >
        {valueFieldByType(selectedType, valueFieldProps)}
        {showFullScreenBtn(selectedType, setShowModal)}
      </FormField>
      <Modal
        show={showModal}
        onHide={() => setShowModal(false)}
        className="editor-modal"
      >
        <Modal.Header closeButton />
        <Modal.Body>
          {valueFieldByType(selectedType, {
            ...valueFieldProps,
            fullScreen: true,
          })}
        </Modal.Body>
      </Modal>
    </React.Fragment>
  );
};

ValueField.propTypes = {
  value: PropTypes.any,
  selectedType: PropTypes.string,
  isMasked: PropTypes.bool,
  onChange: PropTypes.func.isRequired,
  error: PropTypes.string,
};

ValueField.defaultProps = {
  value: '',
  selectedType: '',
  isMasked: false,
  error: '',
};

export default ValueField;
