import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import { HelpBlock, Grid, Col, Row } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import { MB_FORMAT, MEGABYTES } from './constants';
import './memoryAllocationInput.scss';
import { noop } from '../../common/helpers';
import NumericInput from '../common/forms/NumericInput';

const MemoryAllocationInput = ({
  defaultValue,
  label,
  onChange,
  maxValue,
  minValue,
  recommendedMaxValue,
  name,
  id,
  disabled,
}) => {
  const [validationState, setValidationState] = useState(undefined);
  const [value, setValue] = useState(defaultValue);

  useEffect(() => {
    setValue(defaultValue);
  }, [defaultValue]);

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
    setValue(value * 2);
  };

  const handleValueDecrease = () => {
    setValue(value / 2);
  };

  const handleTypedValue = v => {
    setValue(v);
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

  const format = v => `${v} ${MB_FORMAT}`;

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
            id={id}
            format={format}
            parser={parser}
            onChange={handleChange}
            label={label}
            disabled={disabled}
            minValue={minValue}
          />
          <input type="hidden" name={name} value={value * MEGABYTES} />
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
  /** Set the default value of the memory allocation input */
  defaultValue: PropTypes.number,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  maxValue: PropTypes.number,
  /** Set the min value of the numeric input */
  minValue: PropTypes.number,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the name of the numeric input */
  name: NumericInput.propTypes.name,
  /** Set the id of the numeric input */
  id: NumericInput.propTypes.id,
  /** Set whether the numeric input will be disabled or not */
  disabled: NumericInput.propTypes.disabled,
};

MemoryAllocationInput.defaultProps = {
  label: __('Memory'),
  defaultValue: 1,
  onChange: noop,
  recommendedMaxValue: undefined,
  maxValue: undefined,
  minValue: 1,
  name: '',
  id: '',
  disabled: false,
};

export default MemoryAllocationInput;
