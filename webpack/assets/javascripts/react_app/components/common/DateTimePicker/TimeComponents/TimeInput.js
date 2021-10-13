import React from 'react';
import PropTypes from 'prop-types';
import PickTimeTable from './PickTimeTable';
import PickTimeClock from './PickTimeClock';
import { noop } from '../../../../common/helpers';
import { HOUR } from './TimeConstants';

class TimeInput extends React.Component {
  state = {
    isTimeTableOpen: this.props.isTimeTableOpen,
    typeOfTimeInput: HOUR,
  };
  componentDidUpdate = (prevProps) => {
    const { time: nextTime, isTimeTableOpen } = this.props;
    if (prevProps.time !== nextTime) {
      this.setIsTimeTableOpen(isTimeTableOpen);
    }
  };
  setIsTimeTableOpen = (isTimeTableOpen) => {
    this.setState({
      isTimeTableOpen,
    });
  };
  toggleTimeTable = (type) => {
    this.setState({
      typeOfTimeInput: type,
      isTimeTableOpen: !this.state.isTimeTableOpen,
    });
  };
  render() {
    const { time, setSelected } = this.props;
    const { typeOfTimeInput, isTimeTableOpen } = this.state;
    return (
      <div className="timepicker col-md-6">
        {isTimeTableOpen ? (
          <PickTimeTable
            time={time}
            setSelected={setSelected}
            type={typeOfTimeInput}
            show={isTimeTableOpen}
            toggleTimeTable={this.toggleTimeTable}
          />
        ) : (
          <PickTimeClock
            time={time}
            setSelected={setSelected}
            toggleTimeTable={this.toggleTimeTable}
          />
        )}
      </div>
    );
  }
}

TimeInput.propTypes = {
  setSelected: PropTypes.func,
  time: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  isTimeTableOpen: PropTypes.bool,
};
TimeInput.defaultProps = {
  setSelected: noop,
  time: new Date(),
  isTimeTableOpen: false,
};
export default TimeInput;
