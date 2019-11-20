import React from 'react';
import PropTypes from 'prop-types';
import { FormControl } from 'patternfly-react';

import { noop } from '../../../common/helpers';
import AutoComplete from '../../AutoComplete';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import DatePicker from '../DateTimePicker/DatePicker';
import OrderableSelect from './OrderableSelect';
import TimePicker from '../DateTimePicker/TimePicker';

const inputComponents = {
  autocomplete: AutoComplete,
  date: DatePicker,
  dateTime: DateTimePicker,
  orderableSelect: OrderableSelect,
  time: TimePicker,
};

export const registerInputComponent = (name, Component) => {
  inputComponents[name] = Component;
};

const InputFactory = ({ type, ...controlProps }) => {
  if (inputComponents[type]) {
    return (
      <FormControl componentClass={inputComponents[type]} {...controlProps} />
    );
  }
  return <FormControl type={type} {...controlProps} />;
};

InputFactory.propTypes = {
  type: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
    PropTypes.instanceOf(Date),
  ]),
  name: PropTypes.string,
  disabled: PropTypes.bool,
  required: PropTypes.bool,
  className: PropTypes.string,
  onChange: PropTypes.func,
};

InputFactory.defaultProps = {
  name: undefined,
  value: undefined,
  className: '',
  required: false,
  disabled: false,
  onChange: noop,
};

export default InputFactory;
