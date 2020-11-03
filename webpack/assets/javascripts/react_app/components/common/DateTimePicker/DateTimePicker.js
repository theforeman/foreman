import React from 'react';
import PropTypes from 'prop-types';
import {
  FormControl,
  InputGroup,
  Icon,
  OverlayTrigger,
  Popover,
} from 'patternfly-react';
import DateInput from './DateComponents/DateInput';
import TodayButton from './DateComponents/TodayButton';
import TimeInput from './TimeComponents/TimeInput';
import { MONTH } from './DateComponents/DateConstants';
import { formatDateTime } from '../../../common/helpers';
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
    }
    this.setState({
      typeOfDateInput: MONTH,
      isTimeTableOpen: false,
    });
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
      <Popover
        id={id}
        className="bootstrap-datetimepicker-widget dropdown-menu timepicker-sbs"
      >
        <div className="row">
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
        </div>
        <li className="picker-switch accordion-toggle">
          <TodayButton setSelected={this.setSelected} />
        </li>
      </Popover>
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

          <OverlayTrigger
            trigger="click"
            placement={placement}
            overlay={popover}
            rootClose
            container={this}
            onEnter={() => this.setState({ hiddenValue: false })}
          >
            <InputGroup.Addon className="date-time-picker-pf">
              <Icon type="fa" name="calendar" />
            </InputGroup.Addon>
          </OverlayTrigger>
          {!required && (
            <InputGroup.Addon className="clear-button">
              <Icon
                type="fa"
                name="close"
                onClick={() =>
                  this.setState({ hiddenValue: true, value: new Date() })
                }
              />
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
  placement: OverlayTrigger.propTypes.placement,
  name: PropTypes.string,
  required: PropTypes.bool,
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
};
export default DateTimePicker;
