import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { DatePicker as PfDatePicker, Button } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { formatDate } from './dateTimeHelpers';
import './date-time-picker.scss';

const DatePicker = ({
  value: initialValue,
  locale,
  weekStartsOn,
  name,
  id,
  placement,
  required,
}) => {
  const [value, setValue] = useState(formatDate(initialValue));
  return (
    <div className="date-picker-pf-wrapper">
      <PfDatePicker
        value={value}
        onChange={(_event, newValue) => setValue(newValue)}
        locale={locale}
        weekStart={weekStartsOn}
        inputProps={{ name, id }}
        popoverProps={{
          position: placement,
          className: 'date-picker-popover',
          footerContent: (
            <div className="date-picker-input-items">
              <Button
                className="date-picker-input-item"
                ouiaId="today-button"
                onClick={() => setValue(formatDate(new Date()))}
              >
                {__('Today')}
              </Button>
              <Button
                className="date-picker-input-item"
                ouiaId="clear-button"
                onClick={() => setValue('')}
              >
                {__('Clear')}
              </Button>
            </div>
          ),
        }}
        requiredDateOptions={{
          isRequired: required,
          emptyDateText: __('Date is required'),
        }}
      />
    </div>
  );
};

DatePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  name: PropTypes.string,
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  id: PropTypes.string,
  placement: PropTypes.string,
  required: PropTypes.bool,
};
DatePicker.defaultProps = {
  value: null,
  name: null,
  locale: 'en-US',
  weekStartsOn: 1,
  id: 'date-picker-popover',
  placement: 'top',
  required: false,
};
export default DatePicker;
