import React, { useState, useCallback, useEffect } from 'react';
import PropTypes from 'prop-types';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import { HelpBlock, FormGroup, Grid, Col, Row } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import NumericInput from '../common/forms/NumericInput';
import './cpuCoresInput.scss';
import { noop } from '../../common/helpers';

const CPUCoresInput = ({
  label,
  recommendedMaxValue,
  maxValue,
  defaultValue,
  onChange,
  minValue,
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
    <FormGroup validationState={validationState}>
      <Grid>
        <Row>
          <Col>
            <NumericInput
              value={value}
              minValue={minValue}
              onChange={v => handleChange(v)}
              label={label}
            />
          </Col>
        </Row>
        {validationState === 'warning' && (
          <HelpBlock>
            <WarningTriangleIcon className="help-block-icon" />
            {__('Specified value is higher than recommended maximum')}
          </HelpBlock>
        )}
        {validationState === 'error' && (
          <HelpBlock>
            <ErrorCircleOIcon className="help-block-icon" />
            {__('Specified value is higher than maximum value')}
          </HelpBlock>
        )}
      </Grid>
    </FormGroup>
  );
};

CPUCoresInput.propTypes = {
  /** Set the label of the numeric input */
  label: NumericInput.propTypes.label,
  /** Set the default value of the numeric input */
  defaultValue: PropTypes.number,
  /** Set the recommended max value of the numeric input */
  recommendedMaxValue: PropTypes.number,
  /** Set the max value of the numeric input */
  maxValue: PropTypes.number,
  /** Set the min value of the numeric input */
  minValue: PropTypes.number,
  /** Set the onChange function of the numeric input */
  onChange: PropTypes.func,
};

CPUCoresInput.defaultProps = {
  label: __('CPUs'),
  defaultValue: 1,
  minValue: 1,
  recommendedMaxValue: null,
  maxValue: null,
  onChange: noop,
};

export default CPUCoresInput;
