import React from 'react';
import PropTypes from 'prop-types';
import { times } from 'lodash';
import classNames from 'classnames';
import { addMonths, addYears } from './helpers';
import { noop } from '../../../../common/helpers';
import { MONTH, DAY } from './DateConstants';

class YearView extends React.Component {
  state = {
    date: new Date(this.props.date),
    selectedDate: new Date(this.props.date),
  };
  getMonthArray = () => {
    const date = new Date('1/1/1');
    return times(12, i =>
      Intl.DateTimeFormat(this.props.locale, { month: 'short' }).format(
        addMonths(date, i)
      )
    );
  };
  getPrevYear = () => {
    const { date } = this.state;
    this.setState({ date: addYears(date, -1) });
  };
  getNextYear = () => {
    const { date } = this.state;
    this.setState({ date: addYears(date, 1) });
  };
  setSelectedMonth = month => {
    const { date } = this.state;
    date.setMonth(month);
    this.props.setSelected(date);
    this.props.toggleDateView(MONTH);
  };

  render() {
    const { date, selectedDate } = this.state;
    const [currMonth, currYear] = [date.getMonth(), date.getFullYear()];
    const selectedYear = selectedDate.getFullYear();
    const monthArray = this.getMonthArray();
    return (
      <div className="datepicker-months">
        <table className="table-condensed">
          <thead>
            <tr>
              <th className="prev" onClick={this.getPrevYear}>
                <span className="glyphicon glyphicon-chevron-left" />
              </th>
              <th
                className="picker-switch"
                onClick={() => this.props.toggleDateView(DAY)}
                colSpan="5"
              >
                {currYear}
              </th>
              <th className="next" onClick={this.getNextYear}>
                <span className="glyphicon glyphicon-chevron-right" />
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colSpan="7">
                {monthArray.map((month, idx) => (
                  <span
                    onClick={() => this.setSelectedMonth(idx)}
                    className={classNames('month', {
                      active: idx === currMonth && selectedYear === currYear,
                    })}
                    key={idx}
                  >
                    {month}
                  </span>
                ))}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }
}

YearView.propTypes = {
  date: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  setSelected: PropTypes.func,
  toggleDateView: PropTypes.func,
  locale: PropTypes.string,
};

YearView.defaultProps = {
  setSelected: noop,
  toggleDateView: noop,
  date: new Date(),
  locale: 'en-US',
};
export default YearView;
