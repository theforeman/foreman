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
import './date-time-picker.scss';

class DateTimePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: new Date(this.props.value),
      typeOfDateInput: MONTH,
      isTimeTableOpen: false,
      hiddenValue: this.props.hiddenValue,
    };
  }

  formatDate = () => {
    const zeroPadding = n => (n < 10 ? `0${n}` : n);
    const { value } = this.state;
    const date = {
      year: value.getFullYear(),
      month: zeroPadding(value.getMonth() + 1),
      day: zeroPadding(value.getDate()),
      hour: zeroPadding(value.getHours()),
      minutes: zeroPadding(value.getMinutes()),
    };

    return `${date.year}-${date.month}-${date.day} ${date.hour}:${date.minutes}:00`;
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
    const { locale, weekStartsOn, inputProps, id, placement } = this.props;
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
            value={hiddenValue ? '' : this.formatDate()}
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
          <InputGroup.Addon className="clear-button">
            <Icon
              type="fa"
              name="close"
              onClick={() =>
                this.setState({ hiddenValue: true, value: new Date() })
              }
            />
          </InputGroup.Addon>
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
  hiddenValue: PropTypes.bool,
  placement: OverlayTrigger.propTypes.placement,
};
DateTimePicker.defaultProps = {
  value: new Date(),
  locale: 'en-US',
  weekStartsOn: 1,
  inputProps: {},
  id: 'datetime-picker-popover',
  hiddenValue: true,
  placement: 'top',
};
export default DateTimePicker;
