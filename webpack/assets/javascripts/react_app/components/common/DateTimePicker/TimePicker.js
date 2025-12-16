import React from 'react';
import PropTypes from 'prop-types';
import { TimePicker as PfTimePicker } from '@patternfly/react-core';
import { formatTime } from './dateTimeHelpers';

// Note that PF time picker input can not be cleared / set to empty string
const TimePicker = ({ value: initialValue, locale, name, id, onChange }) => (
  <PfTimePicker
    className="time-picker-pf"
    time={formatTime(initialValue)}
    onChange={(_event, value) => {
      if (onChange) onChange(value);
    }}
    locale={locale}
    inputProps={{ name, id }}
    is24Hour
  />
);

TimePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  locale: PropTypes.string,
  name: PropTypes.string,
  id: PropTypes.string,
  onChange: PropTypes.func,
};
TimePicker.defaultProps = {
  value: null,
  locale: 'en-US',
  name: '',
  id: '',
  onChange: null,
};
export default TimePicker;
