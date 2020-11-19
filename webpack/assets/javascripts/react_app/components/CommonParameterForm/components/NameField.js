import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import FormField from '../../common/forms/FormField';

const NameField = ({ value, onChange, error }) => (
  <FormField label={__('Name')} required error={error}>
    <input
      type="text"
      id="common_parameter_name"
      name="common_parameter[name]"
      value={value}
      onChange={e => onChange(e.target.value)}
      className="form-control"
      required
    />
  </FormField>
);

NameField.propTypes = {
  value: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  error: PropTypes.string,
};

NameField.defaultProps = {
  value: '',
  error: '',
};

export default NameField;
