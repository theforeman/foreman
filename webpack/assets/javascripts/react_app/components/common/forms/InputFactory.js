import React from 'react';
import PropTypes from 'prop-types';
import { TextInput } from '@patternfly/react-core';

import { noop } from '../../../common/helpers';
import SearchBar from '../../SearchBar';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import DatePicker from '../DateTimePicker/DatePicker';
import OrderableSelect from './OrderableSelect';
import MemoryAllocationInput from '../../MemoryAllocationInput';
import CounterInput from './CounterInput';
import TimePicker from '../DateTimePicker/TimePicker';
import Select from './Select';

const inputComponents = {
  autocomplete: SearchBar,
  select: Select,
  date: DatePicker,
  dateTime: DateTimePicker,
  orderableSelect: OrderableSelect,
  time: TimePicker,
  memory: MemoryAllocationInput,
  counter: CounterInput,
};

export const registerInputComponent = (name, Component) => {
  inputComponents[name] = Component;
};

export const getComponentClass = name => inputComponents[name] || null;

const InputFactory = ({
  type,
  setError,
  setWarning,
  validated,
  ...controlProps
}) => {
  const CustomComponent = getComponentClass(type);

  if (CustomComponent) {
    return (
      <CustomComponent
        setError={setError}
        setWarning={setWarning}
        type={type}
        {...controlProps}
      />
    );
  }

  const {
    id,
    name,
    value,
    disabled,
    required,
    className,
    onChange,
    ...otherProps
  } = controlProps;

  return (
    <TextInput
      id={id}
      type={type || 'text'}
      name={name}
      value={value}
      isDisabled={disabled}
      isRequired={required}
      className={className}
      onChange={(_event, val) => onChange(val)}
      validated={validated}
      ouiaId={`input-factory-text-input-${id}`}
      aria-label={`text-input-${id}`}
      {...otherProps}
    />
  );
};

InputFactory.propTypes = {
  type: PropTypes.string,
  value: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
    PropTypes.bool,
    PropTypes.instanceOf(Date),
  ]),
  name: PropTypes.string,
  disabled: PropTypes.bool,
  required: PropTypes.bool,
  className: PropTypes.string,
  onChange: PropTypes.func,
  setError: PropTypes.func,
  setWarning: PropTypes.func,
  validated: PropTypes.oneOf(['default', 'success', 'warning', 'error']),
};

InputFactory.defaultProps = {
  type: undefined,
  name: undefined,
  value: undefined,
  className: '',
  required: false,
  disabled: false,
  onChange: noop,
  setError: noop,
  setWarning: noop,
  validated: undefined,
};

export default InputFactory;
