import React from 'react';
import PropTypes from 'prop-types';
import NumericInput from './NumericInput';

import { noop } from '../../../common/helpers';

const ForemanNumericInput = ({
  label,
  className,
  value,
  rawValue,
  onChange,
  format,
  parser,
  step,
  precision,
  minValue,
  disabled,
  readOnly,
  name,
  id,
}) => (
  <>
    <NumericInput
      value={value}
      className={className}
      id={id}
      format={format}
      parser={parser}
      onChange={onChange}
      label={label}
      step={step}
      precision={precision}
      minValue={minValue}
      readOnly={readOnly}
      disabled={disabled}
    />
    <input type="hidden" name={name} value={rawValue} />
  </>
);

ForemanNumericInput.propTypes = {
  label: NumericInput.propTypes.label,
  className: NumericInput.propTypes.className,
  name: NumericInput.propTypes.name,
  id: NumericInput.propTypes.id,
  value: NumericInput.propTypes.value,
  rawValue: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: NumericInput.propTypes.format,
  parser: NumericInput.propTypes.parser,
  step: NumericInput.propTypes.step,
  precision: NumericInput.propTypes.precision,
  minValue: NumericInput.propTypes.minValue,
  onChange: NumericInput.propTypes.onChange,
  readOnly: NumericInput.propTypes.readOnly,
  disabled: NumericInput.propTypes.disabled,
};

ForemanNumericInput.defaultProps = {
  label: '',
  className: '',
  name: '',
  id: '',
  value: 0,
  rawValue: 0,
  format: null,
  parser: undefined,
  step: 1,
  precision: 0,
  minValue: 0,
  onChange: noop,
  disabled: false,
  readOnly: false,
};

export default ForemanNumericInput;
