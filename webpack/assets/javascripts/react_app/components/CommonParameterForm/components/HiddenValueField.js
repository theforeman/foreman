import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import FormField from '../../common/forms/FormField';

const HiddenValueField = ({ value, onChange }) => (
  <FormField label={__('Hidden Value')}>
    <input
      type="checkbox"
      id="common_parameter_hidden_value"
      name="common_parameter[hidden_value]"
      checked={value}
      onChange={() => onChange(!value)}
    />
  </FormField>
);

HiddenValueField.propTypes = {
  value: PropTypes.bool,
  onChange: PropTypes.func.isRequired,
};

HiddenValueField.defaultProps = {
  value: false,
};

export default HiddenValueField;
