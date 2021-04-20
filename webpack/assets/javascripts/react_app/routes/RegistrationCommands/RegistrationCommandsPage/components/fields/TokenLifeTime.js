import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  TextInput,
  InputGroup,
  InputGroupText,
  Checkbox,
} from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { sprintf, translate as __ } from '../../../../../common/I18n';

const TokenLifeTime = ({ value, onChange, handleInvalidField, isLoading }) => {
  const minValue = 1;
  const maxValue = 999999;

  const isValid = v => {
    if (v === 'unlimited') {
      return true;
    }

    return v >= minValue && v <= maxValue;
  };

  const setValue = v => {
    handleInvalidField('Token Life Time', isValid(v));
    onChange(v);
  };

  return (
    <FormGroup
      label={__('Token Life Time (hours)')}
      validated={isValid(value) ? 'default' : 'error'}
      helperTextInvalid={sprintf(
        'Token life time value must be between %s and %s hours.',
        minValue,
        maxValue
      )}
      isRequired
      fieldId="reg_token_life_time_input"
      labelIcon={
        <LabelIcon text={__('Expiration of the authorization token.')} />
      }
    >
      <InputGroup>
        <TextInput
          value={value}
          type="number"
          min={minValue}
          max={maxValue}
          validated={isValid(value) ? 'default' : 'error'}
          isDisabled={isLoading || value === 'unlimited'}
          id="reg_token_life_time_input"
          onChange={v => setValue(v)}
        />
        <InputGroupText>hours</InputGroupText>
        <InputGroupText>
          <Checkbox
            label={__('unlimited')}
            onChange={() => setValue(value === 'unlimited' ? 4 : 'unlimited')}
            id="reg_token_life_time_unlimited_input"
            isDisabled={isLoading}
            isChecked={value === 'unlimited'}
          />
        </InputGroupText>
      </InputGroup>
    </FormGroup>
  );
};

TokenLifeTime.propTypes = {
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  onChange: PropTypes.func.isRequired,
  handleInvalidField: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

TokenLifeTime.defaultProps = {
  value: 4,
};

export default TokenLifeTime;
