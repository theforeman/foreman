import React from 'react';
import PropTypes from 'prop-types';
import { chunk, times } from 'lodash';

import Day from './Day';
import {
  addDays,
  addMonths,
  getMonthStart,
  isEqualDate,
  isWeekend,
} from './helpers';
import Header from './Header';

class MonthView extends React.Component {
  state = {
    selectedDate: new Date(this.props.date),
    date: new Date(this.props.date),
  };

  static getDerivedStateFromProps(props, state) {
    const newDate = new Date(props.date);
    if (newDate !== new Date(state.date)) {
      return {
        selectedDate: newDate,
      };
    }
    return null;
  }

  calendarArray = (date) => {
    const { weekStartsOn } = this.props;
    const monthStart = getMonthStart(new Date(date));
    const offset = monthStart.getDay() - weekStartsOn;
    return chunk(
      times(35, (i) => addDays(monthStart, i - offset)),
      7
    );
  };

  getPrevMonth = () => {
    const { date } = this.state;
    this.setState({ date: addMonths(date, -1) });
  };
  getNextMonth = () => {
    const { date } = this.state;
    this.setState({ date: addMonths(date, 1) });
  };
  setSelected = (day) => {
    this.setState({
      selectedDate: day,
      date: day,
    });
    this.props.setSelected(day);
  };

  render() {
    const { locale, weekStartsOn, toggleDateView } = this.props;
    const { date, selectedDate } = this.state;
    const calendar = this.calendarArray(date);
    return (
      <div className="datepicker-days">
        <table className="table-condensed">
          <Header
            getPrevMonth={this.getPrevMonth}
            getNextMonth={this.getNextMonth}
            date={date}
            locale={locale}
            weekStartsOn={weekStartsOn}
            toggleDateView={toggleDateView}
          />
          <tbody>
            {calendar.map((el, idx) => (
              <tr key={idx}>
                {el.map((day) => (
                  <Day
                    key={day}
                    day={day}
                    setSelected={this.setSelected}
                    classNamesArray={{
                      weekend: isWeekend(day),
                      old: day.getMonth() !== date.getMonth(),
                      active: isEqualDate(day, selectedDate),
                      today: isEqualDate(day, new Date()),
                    }}
                  />
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }
}

MonthView.propTypes = {
  date: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  setSelected: PropTypes.func,
  toggleDateView: PropTypes.func,
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
};

MonthView.defaultProps = {
  setSelected: null,
  toggleDateView: null,
  date: new Date(),
  locale: 'en-US',
  weekStartsOn: 1,
};
export default MonthView;
