import React from 'react';
import { FormControl } from 'patternfly-react';
import PropTypes from 'prop-types';

const InputField = ({ field }) => <FormControl {...field} type="text" />;

InputField.propTypes = {
  field: PropTypes.object.isRequired,
};

export default InputField;
