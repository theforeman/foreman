import React from 'react';
import PropTypes from 'prop-types';
import { FormControl, InputGroup, Icon } from 'patternfly-react';
import { Popover } from '@patternfly/react-core';
import DateInput from './DateComponents/DateInput';
import TodayButton from './DateComponents/TodayButton';
import TimeInput from './TimeComponents/TimeInput';
import { MONTH } from './DateComponents/DateConstants';
import { noop, formatDateTime } from '../../../common/helpers';
import './date-time-picker.scss';

class DateTimePicker extends React.Component {
  get hasDefaultValue() {
    const { value } = this.props;
    return !!Date.parse(value);
  }

  get initialDate() {
    const { value } = this.props;
    return this.hasDefaultValue ? new Date(value) : new Date();
  }

  state = {
    value: this.initialDate,
    typeOfDateInput: MONTH,
    isTimeTableOpen: false,
    hiddenValue: !this.hasDefaultValue,
  };

  setSelected = date => {
    if (Date.parse(date)) {
      const newDate = new Date(date);
      this.setState({ value: newDate });
      this.props.onChange(newDate);
    }
    this.setState({
      typeOfDateInput: MONTH,
      isTimeTableOpen: false,
    });
  };

  clearSelected = () => {
    this.setState({ hiddenValue: true, value: new Date() });
    this.props.onChange(undefined);
  };

  render() {
    const {
      locale,
      weekStartsOn,
      inputProps,
      id,
      placement,
      name,
      required,
    } = this.props;
    const { value, typeOfDateInput, isTimeTableOpen, hiddenValue } = this.state;
    const popover = (
      <div
        className="row bootstrap-datetimepicker-widget timepicker-sbs"
        id={id}
      >
        <DateInput
          date={value}
          setSelected={this.setSelected}
          locale={locale}
          weekStartsOn={weekStartsOn}
          className="col-md-6"
          typeOfDateInput={typeOfDateInput}
        />
        <TimeInput
          time={value}
          setSelected={this.setSelected}
          isTimeTableOpen={isTimeTableOpen}
        />
        <li className="picker-switch accordion-toggle">
          <TodayButton setSelected={this.setSelected} />
        </li>
      </div>
    );
    return (
      <div>
        <InputGroup className="input-group date-time-picker-pf">
          <FormControl
            {...inputProps}
            aria-label="date-picker-input"
            type="text"
            className="date-time-input"
            name={name}
            value={hiddenValue && !required ? '' : formatDateTime(value)}
            onChange={e => this.setSelected(e.target.value)}
          />
          <Popover
            position={placement}
            bodyContent={popover}
            onShown={() => this.setState({ hiddenValue: false })}
          >
            <InputGroup.Addon className="date-time-picker-pf">
              <Icon type="fa" name="calendar" />
            </InputGroup.Addon>
          </Popover>
          {!required && (
            <InputGroup.Addon className="clear-button">
              <Icon type="fa" name="close" onClick={this.clearSelected} />
            </InputGroup.Addon>
          )}
        </InputGroup>
      </div>
    );
  }
}

DateTimePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  inputProps: PropTypes.object,
  id: PropTypes.string,
  placement: PropTypes.string,
  name: PropTypes.string,
  required: PropTypes.bool,
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
  onChange: noop,
};
export default DateTimePicker;
