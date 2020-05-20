import React from 'react';
import PropTypes from 'prop-types';
import { FormControl } from 'patternfly-react';

import { noop } from '../../../common/helpers';
import AutoComplete from '../../AutoComplete';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import DatePicker from '../DateTimePicker/DatePicker';
import OrderableSelect from './OrderableSelect';
import TimePicker from '../DateTimePicker/TimePicker';
import BoolSelect from './BoolSelect';
import HashSelect from './HashSelect';
import ArraySelect from './ArraySelect';

const inputComponents = {
  autocomplete: AutoComplete,
  date: DatePicker,
  dateTime: DateTimePicker,
  orderableSelect: OrderableSelect,
  time: TimePicker,
  boolSelect: BoolSelect,
  hashSelect: HashSelect,
  arraySelect: ArraySelect,
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
  value: '',
  className: '',
  required: false,
  disabled: false,
  onChange: noop,
};

export default InputFactory;
