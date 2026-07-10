import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { DEFAULT_MEMORY_MB, MB_FORMAT, BYTES_PER_MB } from './constants';
import CounterInput from '../common/forms/CounterInput/CounterInput';
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
  const [valueMB, setValueMB] = useState(Math.round(value / BYTES_PER_MB));

  const handleChange = v => {
    setValueMB(v);
    onChange(v * BYTES_PER_MB);
  };
  const handlePlus = () => {
    handleChange(valueMB * 2);
  };
  const handleMinus = () => {
    handleChange(Math.floor(valueMB / 2));
  };
  return (
    <>
      <CounterInput
        unit={MB_FORMAT}
        value={valueMB}
        id={id}
        onChange={handleChange}
        handlePlus={handlePlus}
        handleMinus={handleMinus}
        disabled={disabled}
        min={minValue ? Math.round(minValue / BYTES_PER_MB) : undefined}
        max={maxValue ? Math.round(maxValue / BYTES_PER_MB) : undefined}
        name=""
        setError={setError}
        setWarning={setWarning}
        recommendedMaxValue={
          recommendedMaxValue
            ? Math.round(recommendedMaxValue / BYTES_PER_MB)
            : undefined
        }
      />
      <input type="hidden" name={name} value={valueMB * BYTES_PER_MB} />
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
  value: DEFAULT_MEMORY_MB * BYTES_PER_MB,
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
