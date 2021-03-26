import RCInputNumber from 'rc-input-number';
import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { sprintf, translate as __ } from '../../common/I18n';
import { MB_FORMAT, MEGABYTES } from './constants';
import '../common/forms/NumericInput.scss';
import { noop } from '../../common/helpers';

const MemoryAllocationInput = ({
  value,
  onChange,
  maxValue,
  minValue,
  recommendedMaxValue,
  name,
  id,
  disabled,
  setError,
  setWarning,
}) => {
  const [valueMB, setValueMB] = useState(value / MEGABYTES);

  useEffect(() => {
    const valueBytes = valueMB * MEGABYTES;
    if (maxValue && valueBytes > maxValue) {
      setWarning(null);
      setError(
        sprintf(
          __('Specified value is higher than maximum value %s'),
          `${maxValue / MEGABYTES} ${MB_FORMAT}`
        )
      );
    } else if (recommendedMaxValue && valueBytes > recommendedMaxValue) {
      setError(null);
      setWarning(
        sprintf(
          __('Specified value is higher than recommended maximum %s'),
          `${recommendedMaxValue / MEGABYTES} ${MB_FORMAT}`
        )
      );
    } else {
      setWarning(null);
    }
  }, [valueMB, recommendedMaxValue, maxValue, setError, setWarning]);

  const handleChange = v => {
    if (v === valueMB + 1) {
      v = valueMB * 2;
    } else if (v === valueMB - 1) {
      v = Math.floor(valueMB / 2);
    }
    setValueMB(v);
    onChange(v * MEGABYTES);
  };

  return (
    <>
      <RCInputNumber
        value={valueMB}
        id={id}
        formatter={v => `${v} ${MB_FORMAT}`}
        parser={str => str.replace(/\D/g, '')}
        onChange={handleChange}
        disabled={disabled}
        min={minValue && minValue / MEGABYTES}
        step={1}
        precision={0}
        name=""
        prefixCls="foreman-numeric-input"
      />
      <input type="hidden" name={name} value={valueMB * MEGABYTES} />
    </>
  );
};

MemoryAllocationInput.propTypes = {
  /** Set the default value of the memory allocation input */
  value: PropTypes.number,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  maxValue: PropTypes.number,
  /** Set the min value of the numeric input */
  minValue: PropTypes.number,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the name of the input holding the value in bytes */
  name: PropTypes.string,
  /** Set the id of the numeric input */
  id: PropTypes.string,
  /** Set whether the numeric input will be disabled or not */
  disabled: PropTypes.bool,
  /** Component passes the validation error to this function */
  setError: PropTypes.func,
  /** Component passes the validation warning to this function */
  setWarning: PropTypes.func,
};

MemoryAllocationInput.defaultProps = {
  value: 2048 * MEGABYTES,
  onChange: noop,
  recommendedMaxValue: null,
  maxValue: null,
  minValue: 1,
  name: '',
  id: '',
  disabled: false,
  setError: noop,
  setWarning: noop,
};

export default MemoryAllocationInput;
