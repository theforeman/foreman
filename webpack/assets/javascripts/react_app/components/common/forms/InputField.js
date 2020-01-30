import React from 'react';
import { FormControl } from 'patternfly-react';
import PropTypes from 'prop-types';

const InputField = ({ field, disabled, componentClass }) => (
  <FormControl {...field} componentClass={componentClass} disabled={disabled} />
);

InputField.propTypes = {
  field: PropTypes.object.isRequired,
  disabled: PropTypes.bool,
  componentClass: PropTypes.string,
};

InputField.defaultProps = {
  disabled: false,
  componentClass: 'input',
};

export default InputField;
