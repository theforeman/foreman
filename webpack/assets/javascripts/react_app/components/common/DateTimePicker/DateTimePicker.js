import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import {
  CalendarMonth,
  InputGroup,
  InputGroupItem,
  TextInput,
  Button,
  HelperText,
  HelperTextItem,
  Popover,
} from '@patternfly/react-core';
import { OutlinedCalendarAltIcon } from '@patternfly/react-icons';
import { formatDate, formatTime } from './dateTimeHelpers';
import { noop } from '../../../common/helpers';
import TimePicker from './TimePicker';
import { translate as __ } from '../../../common/I18n';
import './date-time-picker.scss';

const DateTimePicker = ({
  value: initialValue,
  locale,
  weekStartsOn,
  name,
  id,
  placement,
  required,
  inputProps,
  isFutureOnly,
  onChange, // additional prop to allow for custom onChange logic
}) => {
  const [isCalendarOpen, setIsCalendarOpen] = useState(false);
  const [valueDate, setValueDate] = useState(formatDate(initialValue));
  const [valueTime, setValueTime] = useState(formatTime(initialValue));
  const [value, setValue] = useState(`${valueDate} ${valueTime}`);
  const [errorText, setErrorText] = useState(null);

  const intervalRef = useRef(null);
  const onToggleCalendar = () => {
    setIsCalendarOpen(!isCalendarOpen);
  };
  const futureErrorMessage = __('Date must be in the future');
  useEffect(() => {
    const updateError = () => {
      if ((!valueDate || !valueTime || !value) && required) {
        setErrorText(__('Date and time are required'));
      } else if (
        isFutureOnly &&
        new Date().setSeconds(0, 0) > new Date(value).setSeconds(0, 0)
      ) {
        setErrorText(futureErrorMessage);
      } else {
        setErrorText(null);
        onChange(value);
      }
    };
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
    updateError();
    intervalRef.current = setInterval(updateError, 30000); // make sure the error is updated every 30 seconds so isFutureOnly is always up to date
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [valueDate, valueTime, value, required, isFutureOnly]);

  const onSelectCalendar = (_event, newValueDate) => {
    const newDate = formatDate(newValueDate);
    setValueDate(newDate);
    setIsCalendarOpen(!isCalendarOpen);
    setValue(`${newDate} ${valueTime}`);
  };

  const onBlur = () => {
    const [date, time] = value
      .replace(/\s+/g, ' ')
      .trim()
      .split(' ');
    setValueDate(formatDate(date || ''));
    setValueTime(formatTime(time || ''));
    if (date && time) {
      setValue(`${date} ${time}`);
    } else {
      setValue('');
    }
  };
  const onClear = () => {
    setValueDate('');
    setValue('');
  };
  const onSelectTime = newTime => {
    newTime = formatTime(newTime);
    const newDate = formatDate(valueDate);
    setValueTime(newTime);
    setValue(`${newDate} ${newTime}`);
  };
  const onToday = () => {
    const todayDate = formatDate(new Date());
    const todayTime = formatTime(new Date());
    setValueDate(todayDate);
    setValueTime(todayTime);
    setValue(`${todayDate} ${todayTime}`);
  };
  const futureValidator = date => {
    if (
      isFutureOnly &&
      date.setHours(0, 0, 0, 0) < new Date().setHours(0, 0, 0, 0)
    ) {
      return false;
    }
    return true;
  };
  const calendar = (
    <CalendarMonth
      locale={locale}
      weekStart={weekStartsOn}
      date={valueDate ? new Date(valueDate) : ''}
      onChange={onSelectCalendar}
      validators={[futureValidator]}
    />
  );

  return (
    <div className="date-time-picker-pf-wrapper">
      <Popover
        position={placement}
        bodyContent={calendar}
        showClose={false}
        isVisible={isCalendarOpen}
        shouldClose={() => {
          setIsCalendarOpen(false);
        }}
        hasNoPadding
        hasAutoWidth
        className="date-picker-popover"
        footerContent={
          <div className="date-picker-input-items">
            <Button
              className="date-picker-input-item"
              ouiaId="today-button"
              onClick={onToday}
            >
              {__('Today')}
            </Button>
            <Button
              className="date-picker-input-item"
              ouiaId="clear-button"
              onClick={onClear}
            >
              {__('Clear')}
            </Button>
          </div>
        }
      >
        <InputGroup>
          <InputGroupItem className="pf-v5-c-date-picker__input pf-v5-c-date-picker ">
            <TextInput
              ouiaId="datetime-picker-input"
              type="text"
              id={id}
              name={name}
              aria-label="date and time picker"
              value={value}
              onChange={(e, newValue) => {
                setValue(newValue);
                setIsCalendarOpen(false);
              }}
              onBlur={onBlur}
              isRequired={required}
              validated={errorText ? 'error' : 'default'}
              placeholder="YYYY-MM-DD HH:MM"
              className=" pf-v5-c-form-control"
              {...inputProps}
            />
          </InputGroupItem>
          <InputGroupItem className="date-picker-input-item">
            <Button
              ouiaId="toggle-calendar-button"
              variant="control"
              aria-label="Toggle date picker"
              onClick={onToggleCalendar}
            >
              <OutlinedCalendarAltIcon />
            </Button>
          </InputGroupItem>
          <InputGroupItem className="date-picker-input-item">
            <TimePicker
              value={valueTime}
              onChange={onSelectTime}
              id={`${id}-time-picker`}
              locale={locale}
              is24Hour
            />
          </InputGroupItem>
        </InputGroup>
      </Popover>
      {errorText && (
        <HelperText>
          <HelperTextItem variant="error">{errorText}</HelperTextItem>
        </HelperText>
      )}
    </div>
  );
};

DateTimePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  inputProps: PropTypes.object,
  id: PropTypes.string,
  placement: PropTypes.string,
  name: PropTypes.string,
  required: PropTypes.bool,
  isFutureOnly: PropTypes.bool,
  onChange: PropTypes.func,
};

DateTimePicker.defaultProps = {
  value: null,
  locale: 'en-US',
  weekStartsOn: 1,
  inputProps: {},
  id: 'datetime-picker-popover',
  placement: 'top',
  name: undefined,
  required: false,
  isFutureOnly: false,
  onChange: noop,
};
export default DateTimePicker;
