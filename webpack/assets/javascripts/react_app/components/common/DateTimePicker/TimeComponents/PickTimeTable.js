import React from 'react';
import PropTypes from 'prop-types';
import { noop } from '../../../../common/helpers';
import { HOUR } from './TimeConstants';

class PickTimeTable extends React.Component {
  setTime = (newTime, type) => {
    const { time, setSelected, toggleTimeTable } = this.props;
    const hours = time.getHours();
    newTime = parseInt(newTime, 10);
    if (type === 'minute') time.setMinutes(newTime);
    else if (type === 'hour') {
      time.setHours(hours < 12 ? newTime % 12 : (newTime % 12) + 12);
    }
    setSelected(time);
    toggleTimeTable();
  };
  getTimeTable = (array, type) => (
    <div className={`timepicker-${type}s`}>
      <table className="table-condensed">
        <tbody>
          {array.map((row, idx) => (
            <tr key={idx}>
              {row.map((hour) => (
                <td
                  key={hour}
                  className={type}
                  onClick={() => this.setTime(hour, type)}
                >
                  {hour}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
  render() {
    const hoursArray = [
      ['12', '01', '02', '03'],
      ['04', '05', '06', '07'],
      ['08', '09', '10', '11'],
    ];
    const minutesArray = [
      ['00', '05', '10', '15'],
      ['20', '25', '30', '35'],
      ['40', '45', '50', '55'],
    ];
    return this.props.type === HOUR
      ? this.getTimeTable(hoursArray, 'hour')
      : this.getTimeTable(minutesArray, 'minute');
  }
}
PickTimeTable.propTypes = {
  time: PropTypes.instanceOf(Date).isRequired,
  setSelected: PropTypes.func,
  toggleTimeTable: PropTypes.func,
  type: PropTypes.string.isRequired,
};
PickTimeTable.defaultProps = {
  setSelected: noop,
  toggleTimeTable: noop,
};
export default PickTimeTable;
