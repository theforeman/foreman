import NumericInput from 'react-numeric-input';
import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';

const TextInput = ({
  label,
  className,
  value,
  onChange,
  format,
  precision,
  minValue,
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

TextInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: PropTypes.func,
  precision: PropTypes.number,
  minValue: PropTypes.number,
  onChange: PropTypes.func,
};

TextInput.defaultProps = {
  label: '',
  className: '',
  value: 0,
  format: null,
  precision: 0,
  minValue: 0,
  onChange: noop,
};

export default TextInput;
