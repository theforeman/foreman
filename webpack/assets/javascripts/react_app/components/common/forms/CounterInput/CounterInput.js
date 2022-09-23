import React, { useEffect, useState } from 'react';
import RCInputNumber from 'rc-input-number';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

const CounterInput = ({
  id,
  name,
  value,
  disabled,
  step,
  min,
  max,
  recommendedMaxValue,
  onChange,
  setError,
  setWarning,
}) => {
  const [innerValue, setInnerValue] = useState(value);
  useEffect(() => {
    if (max && innerValue > max) {
      setWarning(null);
      setError(__('Specified value is higher than maximum value'));
    } else if (recommendedMaxValue && innerValue > recommendedMaxValue) {
      setError(null);
      setWarning(__('Specified value is higher than recommended maximum'));
    } else {
      setError(null);
      setWarning(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [recommendedMaxValue, max, innerValue]);

  const handleChange = v => {
    setInnerValue(v);
    onChange(v);
  };

  return (
    <RCInputNumber
      value={innerValue}
      name={name}
      id={id}
      min={min}
      disabled={disabled}
      onChange={handleChange}
      step={step}
      prefixCls="foreman-numeric-input"
    />
  );
};

CounterInput.propTypes = {
  /** Set the name of the numeric input */
  name: PropTypes.string,
  /** Set the id of the numeric input */
  id: PropTypes.string,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  max: PropTypes.number,
  /** Set the min value of the numeric input */
  min: PropTypes.number,
  /** Set whether the numeric input will be disabled or not */
  disabled: PropTypes.bool,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the default value of the numeric input */
  value: PropTypes.number,
  /** Set the step, the counter will increase and decrease by */
  step: PropTypes.number,
  /** Component passes the validation error to this function */
  setError: PropTypes.func,
  /** Component passes the validation warning to this function */
  setWarning: PropTypes.func,
};

CounterInput.defaultProps = {
  name: '',
  id: '',
  disabled: false,
  value: 1,
  step: 1,
  min: 1,
  max: null,
  recommendedMaxValue: null,
  onChange: noop,
  setError: noop,
  setWarning: noop,
};

export default CounterInput;
