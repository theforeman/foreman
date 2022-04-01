import React from 'react';
import PropTypes from 'prop-types';
import { FormControl, InputGroup, Icon } from 'patternfly-react';
import { Popover } from '@patternfly/react-core';
import DateInput from './DateComponents/DateInput';
import TodayButton from './DateComponents/TodayButton';
import { formatDate } from '../../../common/helpers';
import './date-time-picker.scss';

class DatePicker extends React.Component {
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
    hiddenValue: !this.hasDefaultValue,
  };

  setSelected = date => {
    if (Date.parse(date)) {
      const newDate = new Date(date);
      this.setState({ value: newDate });
    }
  };

  render() {
    const { locale, weekStartsOn, name, id, placement, required } = this.props;
    const { value, hiddenValue } = this.state;
    const popover = (
      <div className="row bootstrap-datetimepicker-widget" id={id}>
        <DateInput
          date={value}
          setSelected={this.setSelected}
          locale={locale}
          weekStartsOn={weekStartsOn}
          className="col-xs-12"
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
            aria-label="date-time-picker-input"
            type="text"
            className="date-input"
            value={hiddenValue && !required ? '' : formatDate(value)}
            name={name}
            onChange={e => this.setSelected(e.target.value)}
          />
          <Popover
            position={placement}
            bodyContent={popover}
            onShown={() => this.setState({ hiddenValue: false })}
          >
            <InputGroup.Addon className="date-picker-pf">
              <Icon type="fa" name="calendar" />
            </InputGroup.Addon>
          </Popover>
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
