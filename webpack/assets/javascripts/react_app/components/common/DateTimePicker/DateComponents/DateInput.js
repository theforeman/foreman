import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { addMonths } from './helpers';
import MonthView from './MonthView';
import YearView from './YearView';
import DecadeView from './DecadeView';
import { YEAR, DAY, MONTH } from './DateConstants';

class DateInput extends React.Component {
  state = {
    date: new Date(this.props.date),
    typeOfDateInput: this.props.typeOfDateInput,
  };
  static getDerivedStateFromProps(props, state) {
    if (props.date !== state.date) {
      return {
        date: props.date,
        typeOfDateInput: props.typeOfDateInput,
      };
    }
    return null;
  }
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
      date: day,
    });
    this.props.setSelected(day);
  };
  toggleDateView = (type = null) => {
    this.setState({
      typeOfDateInput: type,
    });
  };
  getDateViewByType = (type) => {
    const { date, locale, weekStartsOn, setSelected } = this.props;
    switch (type) {
      case DAY:
        return (
          <DecadeView
            date={date}
            setSelected={setSelected}
            toggleDateView={this.toggleDateView}
          />
        );
      case YEAR:
        return (
          <YearView
            date={date}
            setSelected={setSelected}
            locale={locale}
            toggleDateView={this.toggleDateView}
          />
        );
      default:
        return (
          <MonthView
            date={date}
            setSelected={setSelected}
            locale={locale}
            weekStartsOn={weekStartsOn}
            toggleDateView={this.toggleDateView}
          />
        );
    }
  };
  render() {
    const { className } = this.props;
    const { typeOfDateInput } = this.state;
    return (
      <div className={classNames('datepicker', className)}>
        {this.getDateViewByType(typeOfDateInput)}
      </div>
    );
  }
}

DateInput.propTypes = {
  date: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  setSelected: PropTypes.func,
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
  className: PropTypes.string,
  typeOfDateInput: PropTypes.string,
};

DateInput.defaultProps = {
  setSelected: null,
  date: new Date(),
  locale: 'en-US',
  weekStartsOn: 1,
  className: '',
  typeOfDateInput: MONTH,
};
export default DateInput;
