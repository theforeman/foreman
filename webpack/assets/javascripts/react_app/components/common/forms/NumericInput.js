import ReactNumericInput from 'react-numeric-input';
import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import { wrapInput } from './FormField';

/**
 * NumericInput field.
 *
 * === Change handler
 * It does not support *onChange* prop as a change handler,
 * because the it has different behaviour and would confuse users.
 * Use *onValueChange* instead.
 */
const NumericInput = ({
  className,
  value,
  onValueChange,
  format,
  precision,
  minValue,
}) => (
  <ReactNumericInput
    className={className}
    format={format}
    min={minValue}
    value={value}
    precision={precision}
    onChange={onValueChange}
  />
);

NumericInput.propTypes = {
  className: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: PropTypes.func,
  precision: PropTypes.number,
  minValue: PropTypes.number,
  /**
   * Only supported change handler.
   *
   * @param valueAsNumber
   * @param valueAsString
   * @param input the underlying input
   */
  onValueChange: PropTypes.func,
};

NumericInput.defaultProps = {
  className: '',
  value: 0,
  format: null,
  precision: 0,
  minValue: 0,
  onValueChange: noop,
};

export default wrapInput('numeric', NumericInput);
