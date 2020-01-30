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
    value: this.props.value == null ? new Date() : new Date(this.props.value),
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
    const { locale, weekStartsOn, name, placement } = this.props;
    const popover = (
      <Popover
        id="popover-date-picker"
        className="bootstrap-datepicker-widget dropdown-menu usetwentyfour"
      >
        <div className="container">
          <div className="row">
            <DateInput
              date={this.state.value}
              setSelected={this.setSelected}
              locale={locale}
              weekStartsOn={weekStartsOn}
            />
          </div>
          <div className="row pull-right">
            <TodayButton setSelected={this.setSelected} />
          </div>
        </div>
      </Popover>
    );
    return (
      <div>
        <OverlayTrigger
          trigger="click"
          placement={placement}
          overlay={popover}
          rootClose
        >
          <InputGroup className="input-group date-time-picker-pf">
            <FormControl
              aria-label="date-time-picker-input"
              type="text"
              value={this.formatDate()}
              name={name}
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
  name: PropTypes.string,
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  placement: OverlayTrigger.propTypes.placement,
};
DatePicker.defaultProps = {
  value: new Date(),
  name: null,
  locale: 'en-US',
  weekStartsOn: 1,
  placement: 'top',
};
export default DatePicker;
