import React from 'react';
import PropTypes from 'prop-types';
import chunk from 'lodash/chunk';
import times from 'lodash/times';
import Day from './Day';
import {
  addDays,
  addMonths,
  getMonthStart,
  isEquelDate,
  isWeekend,
} from './helpers';
import Header from './Header';

class MonthView extends React.Component {
  state = {
    selectedDate: new Date(this.props.date),
    date: new Date(this.props.date),
  };

  componentDidUpdate = prevProps => {
    const newDate = this.props.date;
    if (prevProps.date !== newDate) {
      // TODO: Fix #27114 - stop violating react/no-did-update-set-state
      // eslint-disable-next-line react/no-did-update-set-state
      this.setState({
        selectedDate: newDate,
        date: newDate,
      });
    }
  };

  calendarArray = date => {
    const { weekStartsOn } = this.props;
    const monthStart = getMonthStart(new Date(date));
    const offset = monthStart.getDay() - weekStartsOn;
    return chunk(times(35, i => addDays(monthStart, i - offset)), 7);
  };

  getPrevMonth = () => {
    const { date } = this.state;
    this.setState({ date: addMonths(date, -1) });
  };
  getNextMonth = () => {
    const { date } = this.state;
    this.setState({ date: addMonths(date, 1) });
  };
  setSelected = day => {
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
                {el.map(day => (
                  <Day
                    key={day}
                    day={day}
                    setSelected={this.setSelected}
                    classNamesArray={{
                      weekend: isWeekend(day),
                      old: day.getMonth() !== date.getMonth(),
                      active: isEquelDate(day, selectedDate),
                      today: isEquelDate(day, new Date()),
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
