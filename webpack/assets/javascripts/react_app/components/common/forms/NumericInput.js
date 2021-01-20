import RCInputNumber from 'rc-input-number';
import React from 'react';
import PropTypes from 'prop-types';
import './NumericInput.scss';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';

const NumericInput = ({
  label,
  className,
  value,
  onChange,
  format,
  parser,
  step,
  precision,
  minValue,
  disabled,
  readOnly,
  name,
}) => (
  <CommonForm label={label} className={className}>
    <RCInputNumber
      formatter={format}
      parser={parser}
      step={step}
      min={minValue}
      value={value}
      precision={precision}
      onChange={onChange}
      disabled={disabled}
      readOnly={readOnly}
      prefixCls="foreman-numeric-input"
      name={name}
    />
  </CommonForm>
);

NumericInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  name: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: PropTypes.func,
  parser: PropTypes.func,
  step: PropTypes.number,
  precision: PropTypes.number,
  minValue: PropTypes.number,
  onChange: PropTypes.func,
  readOnly: PropTypes.bool,
  disabled: PropTypes.bool,
};

NumericInput.defaultProps = {
  label: '',
  className: '',
  name: '',
  value: 0,
  format: null,
  parser: undefined,
  step: 1,
  precision: 0,
  minValue: 0,
  onChange: noop,
  disabled: false,
  readOnly: false,
};

export default NumericInput;
