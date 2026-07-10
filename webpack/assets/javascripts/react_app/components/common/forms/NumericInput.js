import RCInputNumber from 'rc-input-number';
import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import './NumericInput.scss';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';
import { deprecate } from '../../../common/DeprecationService';

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
  id,
}) => {
  useEffect(() => {
    deprecate(
      'forms/NumericInput',
      'components/common/forms/CounterInput/CounterInput.js, or NumberInput from @patternfly/react-core',
      '3.20'
    );
  }, []);
  return (
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
        id={id}
      />
    </CommonForm>
  );
};

NumericInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  name: PropTypes.string,
  id: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  format: PropTypes.func,
  parser: PropTypes.func,
  step: PropTypes.number,
  precision: PropTypes.number,
  minValue: PropTypes.number,
  disabled: PropTypes.bool,
  onChange: PropTypes.func,
  readOnly: PropTypes.bool,
};

NumericInput.defaultProps = {
  label: '',
  className: '',
  name: '',
  id: '',
  value: 0,
  format: null,
  parser: undefined,
  step: 1,
  disabled: false,
  precision: 0,
  minValue: 0,
  onChange: noop,
  readOnly: false,
};

export default NumericInput;
