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

class DatePicker extends React.Component {
  state = {
    value: new Date(this.props.value),
  };
  formatDate = () => {
    const { locale } = this.props;
    const { value } = this.state;
    const options = { year: 'numeric', month: 'numeric', day: 'numeric' };
    return value.toLocaleString(locale, options);
  };
  setSelected = date => {
    if (Date.parse(date)) {
      const newDate = new Date(date);
      this.setState({ value: newDate });
    }
  };
  render() {
    const { locale, weekStartsOn } = this.props;
    const popover = (
      <Popover
        id="popover-date-picker"
        className="bootstrap-datepicker-widget dropdown-menu usetwentyfour"
      >
        <ul className="list-unstyled">
          <li>
            <DateInput
              date={this.state.value}
              setSelected={this.setSelected}
              locale={locale}
              weekStartsOn={weekStartsOn}
            />
          </li>
          <li className="picker-switch accordion-toggle">
            <TodayButton setSelected={this.setSelected} />
          </li>
        </ul>
      </Popover>
    );
    return (
      <div>
        <OverlayTrigger
          trigger="click"
          placement="top"
          overlay={popover}
          rootClose
        >
          <InputGroup className="input-group date-time-picker-pf">
            <FormControl
              aria-label="date-time-picker-input"
              type="text"
              value={this.formatDate()}
              onChange={e => this.setSelected(e.target.value)}
            />
            <InputGroup.Addon className="date-picker-pf">
              <Icon type="fa" name="calendar" />
            </InputGroup.Addon>
          </InputGroup>
        </OverlayTrigger>
      </div>
    );
  }
}

DatePicker.propTypes = {
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
};
DatePicker.defaultProps = {
  value: new Date(),
  locale: 'en-US',
  weekStartsOn: 1,
};
export default DatePicker;
