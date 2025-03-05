import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  TextInput,
  InputGroup,
  InputGroupText,
  Checkbox,
  InputGroupItem,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';

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
    handleInvalidField('Token life time', isValid(v));
    onChange(v);
  };

  return (
    <FormGroup
      label={__('Token life time')}
      fieldId="reg_token_life_time_input"
      labelIcon={
        <LabelIcon text={__('Expiration of the authorization token.')} />
      }
    >
      <InputGroup>
        <InputGroupItem isFill>
          <TextInput
            ouiaId="reg_token_life_time_input"
            value={value}
            type="number"
            min={minValue}
            max={maxValue}
            validated={isValid(value) ? 'default' : 'error'}
            isDisabled={isLoading || value === 'unlimited'}
            id="reg_token_life_time_input"
            onChange={(_event, v) => setValue(v)}
          />
        </InputGroupItem>
        <InputGroupText>{__('hours')}</InputGroupText>
        <InputGroupText>
          <Checkbox
            ouiaId="reg_unlimited_token_life_time"
            label={__('unlimited')}
            onChange={() => setValue(value === 'unlimited' ? 4 : 'unlimited')}
            id="reg_unlimited_token_life_time"
            isDisabled={isLoading}
            isChecked={value === 'unlimited'}
          />
        </InputGroupText>
      </InputGroup>
      {!isValid(value) && (
        <FormHelperText>
          <HelperText>
            <HelperTextItem icon={<ExclamationCircleIcon />} variant="error">
              {sprintf(
                'Token life time value must be between %s and %s hours.',
                minValue,
                maxValue
              )}
            </HelperTextItem>
          </HelperText>
        </FormHelperText>
      )}
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
