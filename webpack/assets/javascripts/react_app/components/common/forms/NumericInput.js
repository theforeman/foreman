import ReactNumericInput from 'react-numeric-input';
import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';

const NumericInput = ({
  label,
  className,
  value,
  onValueChange,
  format,
  precision,
  minValue,
}) => (
  <CommonForm label={label} className={`common-numericInput ${className}`}>
    <ReactNumericInput
      format={format}
      min={minValue}
      value={value}
      precision={precision}
      onChange={onValueChange}
    />
  </CommonForm>
);

NumericInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: PropTypes.func,
  precision: PropTypes.number,
  minValue: PropTypes.number,
  onValueChange: PropTypes.func,
};

NumericInput.defaultProps = {
  label: '',
  className: '',
  value: 0,
  format: null,
  precision: 0,
  minValue: 0,
  onValueChange: noop,
};

export default NumericInput;
