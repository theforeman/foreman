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
  state = {
    value: new Date(this.props.value),
    typeOfDateInput: MONTH,
    isTimeTableOpen: false,
    left: 'auto',
  };
  formatDate = () => {
    const { locale } = this.props;
    const { value } = this.state;
    const options = [
      { year: 'numeric', month: 'numeric', day: 'numeric' },
      { hour: '2-digit', minute: '2-digit' },
    ];
    return `${value.toLocaleString(locale, options[0])} ${value.toLocaleString(
      locale,
      options[1]
    )}`;
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
  getLeft = () => {
    const div = document
      .getElementsByClassName('date-time-picker-pf')[0]
      .getBoundingClientRect();
    this.setState({ left: div.left });
  };
  render() {
    const { locale, weekStartsOn, inputProps } = this.props;
    const { value, typeOfDateInput, isTimeTableOpen, left } = this.state;
    const popover = (
      <Popover
        id="popover-date-picker1"
        className="bootstrap-datetimepicker-widget dropdown-menu timepicker-sbs"
        style={{ left: `${left} !important` }}
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
        <OverlayTrigger
          trigger="click"
          placement="top"
          overlay={popover}
          rootClose
          shouldUpdatePosition
        >
          <InputGroup
            className="input-group date-time-picker-pf"
            onClick={this.getLeft}
          >
            <FormControl
              {...inputProps}
              aria-label="date-picker-input"
              type="text"
              value={this.formatDate()}
              onChange={e => this.setSelected(e.target.value)}
            />
            <InputGroup.Addon className="date-time-picker-pf">
              <Icon type="fa" name="calendar" />
            </InputGroup.Addon>
          </InputGroup>
        </OverlayTrigger>
      </div>
    );
  }
}

DateTimePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  inputProps: PropTypes.object,
};
DateTimePicker.defaultProps = {
  value: new Date(),
  locale: 'en-US',
  weekStartsOn: 1,
  inputProps: {},
};
export default DateTimePicker;
