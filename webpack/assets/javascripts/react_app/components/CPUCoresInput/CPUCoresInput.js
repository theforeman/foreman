import React, { useCallback, useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import { HelpBlock, Grid, Col, Row } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import NumericInput from '../common/forms/NumericInput';
import './cpuCoresInput.scss';
import { noop } from '../../common/helpers';

const CPUCoresInput = ({
  defaultValue,
  label,
  recommendedMaxValue,
  maxValue,
  onChange,
  minValue,
  disabled,
  name,
  id,
}) => {
  const [value, setValue] = useState(defaultValue);

  useEffect(() => {
    setValue(defaultValue);
  }, [defaultValue]);

  const getValidationState = useCallback(() => {
    if (value > maxValue && maxValue != null) return 'error';
    else if (value > recommendedMaxValue && recommendedMaxValue != null)
      return 'warning';
    return null;
  }, [recommendedMaxValue, maxValue, value]);

  const handleChange = v => {
    setValue(v);
    onChange(v);
  };

  const validationState = getValidationState();

  return (
    <Grid>
      <Row>
        <Col>
          <NumericInput
            value={value}
            minValue={minValue}
            onChange={handleChange}
            label={label}
            disabled={disabled}
            name={name}
            id={id}
          />
        </Col>
      </Row>
      {validationState !== null && (
        <Row>
          <Col md={2} />
          <Col md={4} className="form-group">
            {validationState === 'warning' && (
              <HelpBlock>
                <WarningTriangleIcon className="warning-icon" />
                {__('Specified value is higher than recommended maximum')}
              </HelpBlock>
            )}
            {validationState === 'error' && (
              <HelpBlock>
                <ErrorCircleOIcon className="error-icon" />
                {__('Specified value is higher than maximum value')}
              </HelpBlock>
            )}
          </Col>
        </Row>
      )}
    </Grid>
  );
};

CPUCoresInput.propTypes = {
  /** Set the label of the numeric input */
  label: NumericInput.propTypes.label,
  /** Set the name of the numeric input */
  name: NumericInput.propTypes.name,
  /** Set the id of the numeric input */
  id: NumericInput.propTypes.id,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  maxValue: PropTypes.number,
  /** Set the min value of the numeric input */
  minValue: PropTypes.number,
  /** Set whether the numeric input will be disabled or not */
  disabled: NumericInput.propTypes.disabled,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
  /** Set the default value of the numeric input */
  defaultValue: PropTypes.number,
};

CPUCoresInput.defaultProps = {
  label: __('CPUs'),
  name: '',
  id: '',
  disabled: false,
  defaultValue: 1,
  minValue: 1,
  recommendedMaxValue: null,
  maxValue: null,
  onChange: noop,
};

export default CPUCoresInput;
