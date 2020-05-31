import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import { HelpBlock, Grid, Col, Row } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import NumericInput from '../common/forms/NumericInput';
import { GB_FORMAT, MB_FORMAT, GB_STEP, MB_STEP } from './constants';
import './memoryAllocationInput.scss';
import { noop } from '../../common/helpers';

const MemoryAllocationInput = ({
  label,
  defaultValue,
  onChange,
  maxValue,
  recommendedMaxValue,
  name,
  disabled,
}) => {
  const [value, setValue] = useState(defaultValue);
  const [validationState, setValidationState] = useState(undefined);

  useEffect(() => {
    if (value > maxValue && maxValue !== undefined) {
      setValidationState('error');
    } else if (
      value > recommendedMaxValue &&
      recommendedMaxValue !== undefined
    ) {
      setValidationState('warning');
    } else {
      setValidationState(undefined);
    }
  }, [recommendedMaxValue, maxValue, value]);

  const handleValueIncrease = () => {
    if (value >= GB_STEP) {
      setValue(value + GB_STEP);
    } else {
      setValue(value + MB_STEP);
    }
  };

  const handleValueDecrease = () => {
    if (value <= GB_STEP) {
      setValue(value - MB_STEP);
    } else {
      setValue(value - GB_STEP);
    }
  };

  const handleTypedValue = v => {
    if (v > GB_STEP) {
      setValue(Math.round(v / GB_STEP) * GB_STEP);
    } else {
      setValue(Math.round(v / MB_STEP) * MB_STEP);
    }
  };

  const handleChange = v => {
    if (v === value + 1) {
      handleValueIncrease();
    } else if (v === value - 1) {
      handleValueDecrease();
    } else {
      handleTypedValue(v);
    }
    onChange(value);
  };

  const format = v => {
    // used the buttons
    if (v % MB_STEP === 0) {
      if (v >= GB_STEP) {
        return `${v / GB_STEP} ${GB_FORMAT}`;
      }
      return `${v} ${MB_FORMAT}`;
    }

    // typed value
    return v;
  };

  const helpBlock = () => {
    if (validationState === 'warning') {
      return (
        <HelpBlock>
          <WarningTriangleIcon className="warning-icon" />
          {__('Specified value is higher than recommended maximum')}
        </HelpBlock>
      );
    } else if (validationState === 'error') {
      return (
        <HelpBlock>
          <ErrorCircleOIcon className="error-icon" />
          {__('Specified value is higher than maximum value')}
        </HelpBlock>
      );
    }
    return undefined;
  };

  const parser = str => str.replace(/\D/g, '');
  return (
    <Grid>
      <Row>
        <Col>
          <NumericInput
            value={value}
            format={format}
            parser={parser}
            onChange={handleChange}
            label={label}
            name={name}
            disabled={disabled}
          />
        </Col>
      </Row>
      <Row>
        <Col md={2} />
        <Col md={4} className="form-group">
          {validationState !== undefined && helpBlock()}
        </Col>
      </Row>
    </Grid>
  );
};

MemoryAllocationInput.propTypes = {
  /** Set the label of the memory allocation input */
  label: PropTypes.string,
  /** Set the default value of the numeric input */
  defaultValue: PropTypes.number,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  maxValue: PropTypes.number,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the name of the numeric input */
  name: NumericInput.propTypes.name,
  /** Set whether the numeric input will be disabled or not */
  disabled: NumericInput.propTypes.disabled,
};

MemoryAllocationInput.defaultProps = {
  label: __('Memory'),
  defaultValue: 1,
  onChange: noop,
  recommendedMaxValue: undefined,
  maxValue: undefined,
  name: '',
  disabled: false,
};

export default MemoryAllocationInput;
