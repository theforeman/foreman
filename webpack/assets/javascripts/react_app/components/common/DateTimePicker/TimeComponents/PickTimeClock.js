import React from 'react';
import PropTypes from 'prop-types';
import { noop } from '../../../../common/helpers';
import { HOUR, MINUTE } from './TimeConstants';

class PickTimeClock extends React.Component {
  state = {
    ampm: this.props.time.getHours() >= 12 ? 'PM' : 'AM',
  };
  componentDidUpdate = (prevProps) => {
    const newTime = this.props.time;
    if (prevProps.time !== newTime) {
      this.setAMPM(newTime);
    }
  };
  setAMPM = (time) => {
    this.setState({ ampm: time.getHours() >= 12 ? 'PM' : 'AM' });
  };
  setTime = (type, amount) => {
    const { time } = this.props;
    if (type === HOUR) {
      time.setHours(time.getHours() + amount);
    } else if (type === MINUTE) {
      time.setMinutes(time.getMinutes() + amount);
    }
    this.props.setSelected(time);
  };
  toggleAMPM = () => {
    const { time } = this.props;
    if (this.state.ampm === 'AM') {
      time.setHours(time.getHours() + 12);
      this.setState({ ampm: 'PM' });
    } else {
      time.setHours(time.getHours() - 12);
      this.setState({ ampm: 'AM' });
    }
    this.props.setSelected(time);
  };
  render() {
    const { time, toggleTimeTable } = this.props;
    const minutes = time.getMinutes();
    const hours = time.getHours() % 12 || 12;

    return (
      <div className="timepicker-picker">
        <table>
          <tbody>
            <tr>
              <td onClick={() => this.setTime(HOUR, 1)}>
                <a className="btn clock-btn increment-hour">
                  <span className="glyphicon glyphicon-chevron-up" />
                </a>
              </td>
              <td className="separator" />
              <td onClick={() => this.setTime(MINUTE, 1)}>
                <a className="btn clock-btn increment-min">
                  <span className="glyphicon glyphicon-chevron-up" />
                </a>
              </td>
              <td className="separator" />
            </tr>
            <tr>
              <td onClick={() => toggleTimeTable(HOUR)}>
                <span className="timepicker-hour">
                  {`${hours}`.padStart(2, '0')}
                </span>
              </td>
              <td className="separator">:</td>
              <td onClick={() => toggleTimeTable(MINUTE)}>
                <span className="timepicker-minute">
                  {`${minutes}`.padStart(2, '0')}
                </span>
              </td>
              <td>
                <button
                  type="button"
                  className="btn btn-primary ampm-toggle"
                  onClick={() => this.toggleAMPM()}
                >
                  {this.state.ampm}
                </button>
              </td>
            </tr>
            <tr>
              <td>
                <a
                  className="btn clock-btn decrement-hour"
                  onClick={() => this.setTime(HOUR, -1)}
                >
                  <span className="glyphicon glyphicon-chevron-down" />
                </a>
              </td>
              <td className="separator" />
              <td>
                <a
                  className="btn clock-btn decrement-min"
                  onClick={() => this.setTime(MINUTE, -1)}
                >
                  <span className="glyphicon glyphicon-chevron-down" />
                </a>
              </td>
              <td className="separator" />
            </tr>
          </tbody>
        </table>
      </div>
    );
  }
}

PickTimeClock.propTypes = {
  time: PropTypes.instanceOf(Date).isRequired,
  setSelected: PropTypes.func,
  toggleTimeTable: PropTypes.func,
};
PickTimeClock.defaultProps = {
  setSelected: noop,
  toggleTimeTable: noop,
};
export default PickTimeClock;
