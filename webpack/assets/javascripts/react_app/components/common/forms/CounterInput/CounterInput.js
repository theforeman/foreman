import React, { useEffect, useState } from 'react';
import { NumberInput } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __, sprintf } from '../../../../common/I18n';
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
  widthChars,
  unit,
  handlePlus,
  handleMinus,
}) => {
  const parseValue = v => {
    if (v === '' || v == null) return v;
    const parsed = Number(v);
    return Number.isNaN(parsed) ? v : parsed;
  };

  const [innerValue, setInnerValue] = useState(() => parseValue(value));

  useEffect(() => {
    setInnerValue(parseValue(value));
  }, [value]);

  const getValidated = () => {
    if (max && innerValue > max) return 'error';
    if (recommendedMaxValue && innerValue > recommendedMaxValue)
      return 'warning';
    return 'default';
  };
  const validated = getValidated();

  useEffect(() => {
    if (validated === 'error') {
      setWarning(null);
      setError(
        sprintf(
          __('Specified value is higher than maximum value %s%s'),
          max,
          unit ? ` ${unit}` : ''
        )
      );
    } else if (validated === 'warning') {
      setError(null);
      setWarning(
        sprintf(
          __('Specified value is higher than recommended maximum %s%s'),
          recommendedMaxValue,
          unit ? ` ${unit}` : ''
        )
      );
    } else {
      setError(null);
      setWarning(null);
    }
  }, [validated, max, recommendedMaxValue, setError, setWarning, unit]);
  const setValue = newValue => {
    setInnerValue(newValue);
    onChange(newValue);
  };
  const handleChange = event => {
    const inputValue = event.target.value;
    if (inputValue === '') {
      setValue('');
    } else {
      const parsed = parseInt(inputValue, 10);
      const clamped = Number.isNaN(parsed) ? min : parsed;
      setValue(min != null ? Math.max(min, clamped) : clamped);
    }
  };

  const defaultHandlePlus = () => {
    if (handlePlus) {
      handlePlus(innerValue);
    } else {
      const newValue = (innerValue || 0) + (step || 1);
      setValue(newValue);
    }
  };

  const defaultHandleMinus = () => {
    if (handleMinus) {
      handleMinus(innerValue);
    } else {
      const current = innerValue || 0;
      if (min != null && current <= min) return;
      const newValue = current - (step || 1);
      setValue(min != null ? Math.max(min, newValue) : newValue);
    }
  };

  return (
    <NumberInput
      value={innerValue ?? 0}
      inputName={name}
      inputProps={{ id, name }}
      min={min}
      max={max}
      isDisabled={disabled}
      onChange={handleChange}
      onPlus={defaultHandlePlus}
      onMinus={defaultHandleMinus}
      validated={validated}
      widthChars={widthChars}
      unit={unit}
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
  /** Set the min value of the numeric input, undefined will be defaulted to 0 */
  min: PropTypes.number,
  /** Set whether the numeric input will be disabled or not */
  disabled: PropTypes.bool,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the default value of the numeric input */
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  /** Set the step, the counter will increase and decrease by */
  step: PropTypes.number,
  /** Component passes the validation error to this function */
  setError: PropTypes.func,
  /** Component passes the validation warning to this function */
  setWarning: PropTypes.func,
  /** Set the width of the numeric input in characters */
  widthChars: PropTypes.number,
  /** Set the unit of the numeric input */
  unit: PropTypes.string,
  /** Override the default handlePlus function */
  handlePlus: PropTypes.func,
  /** Override the default handleMinus function */
  handleMinus: PropTypes.func,
};

CounterInput.defaultProps = {
  name: '',
  id: '',
  disabled: false,
  value: 1,
  step: 1,
  min: 1,
  max: undefined,
  recommendedMaxValue: null,
  onChange: noop,
  setError: noop,
  setWarning: noop,
  widthChars: 10,
  unit: '',
  handlePlus: null,
  handleMinus: null,
};

export default CounterInput;
