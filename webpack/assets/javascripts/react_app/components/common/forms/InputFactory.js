import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { FormControl } from 'patternfly-react';

import AutoComplete from '../../AutoComplete';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import DatePicker from '../DateTimePicker/DatePicker';
import OrderableSelect from './OrderableSelect';
import TimePicker from '../DateTimePicker/TimePicker';
import Select from './Select';

const inputComponents = {
  autocomplete: AutoComplete,
  select: Select,
  date: DatePicker,
  dateTime: DateTimePicker,
  orderableSelect: OrderableSelect,
  time: TimePicker,
};

export const registerInputComponent = (name, Component) => {
  inputComponents[name] = Component;
};

export const getComponentClass = name => inputComponents[name] || 'input';

const InputFactory = ({ type, onChange, value, ...controlProps }) => {
  const [stateValue, setstateValue] = useState(value || '');
  const defaultOnChange = e => setstateValue(e.target.value);
  return (
    <FormControl
      componentClass={getComponentClass(type)}
      type={type}
      value={stateValue}
      onChange={onChange || defaultOnChange}
      {...controlProps}
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
};

InputFactory.defaultProps = {
  type: undefined,
  name: undefined,
  value: undefined,
  className: '',
  required: false,
  disabled: false,
  onChange: null,
};

export default InputFactory;
