import NumericInput from 'react-numeric-input';
import React from 'react';

import CommonForm from './CommonForm';

const TextInput = ({
  label,
  className = '',
  value,
  onChange,
  format,
  precision = 0,
  minValue = 0,
}) => (
  <CommonForm label={label} className={`common-numericInput ${className}`}>
    <NumericInput
      format={format}
      min={minValue}
      value={value}
      precision={precision}
      onChange={onChange}
    />
  </CommonForm>
);

export default TextInput;
