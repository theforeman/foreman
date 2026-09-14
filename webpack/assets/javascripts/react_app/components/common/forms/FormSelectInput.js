import React from 'react';
import PropTypes from 'prop-types';
import {
  FormGroup,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';

import { renderPF5Options } from '../../../common/selectOptionsHelpers';
import { noop } from '../../../common/helpers';

const FormSelectInput = ({
  id,
  name,
  value,
  label,
  options,
  disabled,
  validated,
  onChange,
}) => {
  const fieldId = id || name;

  const select = (
    <FormSelect
      id={fieldId}
      name={name}
      value={value}
      validated={validated}
      isDisabled={disabled}
      ouiaId={`form-select-input-${fieldId}`}
      onChange={(_event, selection) => onChange(selection)}
    >
      <FormSelectOption value="" label="" />
      {renderPF5Options(options)}
    </FormSelect>
  );

  if (!label) {
    return select;
  }

  return (
    <FormGroup label={label} fieldId={fieldId}>
      {select}
    </FormGroup>
  );
};

FormSelectInput.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  label: PropTypes.string,
  options: PropTypes.oneOfType([PropTypes.array, PropTypes.object]),
  disabled: PropTypes.bool,
  validated: PropTypes.oneOf(['default', 'success', 'warning', 'error']),
  onChange: PropTypes.func,
};

FormSelectInput.defaultProps = {
  id: null,
  name: null,
  value: undefined,
  label: '',
  options: {},
  disabled: false,
  validated: 'default',
  onChange: noop,
};

export default FormSelectInput;
