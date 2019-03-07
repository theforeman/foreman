import React from 'react';
import PropTypes from 'prop-types';
import { times } from 'lodash';
import { addYears } from './helpers';
import { noop } from '../../../../common/helpers';
import { DecadeViewHeader } from './DecadeViewHeader';
import { DecadeViewTable } from './DecadeViewTable';
import { YEAR } from './DateConstants';

class DecadeView extends React.Component {
  state = {
    date: new Date(this.props.date),
    selectedDate: new Date(this.props.date),
  };
  getYearArray = () => {
    const { date } = this.state;
    date.setFullYear(Math.floor(date.getFullYear() / 10) * 10);
    return times(12, i => addYears(date, i).getFullYear());
  };
  getPrevDecade = () => {
    const { date } = this.state;
    this.setState({ date: addYears(date, -10) });
  };
  getNextDecade = () => {
    const { date } = this.state;
    this.setState({ date: addYears(date, 10) });
  };
  setSelectedYear = year => {
    const { setSelected, toggleDateView } = this.props;
    const { date } = this.state;
    date.setFullYear(year);
    setSelected(date);
    toggleDateView(YEAR);
  };

  render() {
    const { date, selectedDate } = this.state;
    const currDecade = Math.floor(date.getFullYear() / 10) * 10;
    const selectedYear = selectedDate.getFullYear();
    const yearArray = this.getYearArray();
    return (
      <div className="datepicker-years">
        <table className="table-condensed">
          <DecadeViewHeader
            currDecade={currDecade}
            getNextDecade={this.getNextDecade}
            getPrevDecade={this.getPrevDecade}
          />
          <DecadeViewTable
            selectedYear={selectedYear}
            yearArray={yearArray}
            setSelectedYear={this.setSelectedYear}
          />
        </table>
      </div>
    );
  }
}

DecadeView.propTypes = {
  date: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  setSelected: PropTypes.func,
  toggleDateView: PropTypes.func,
};

DecadeView.defaultProps = {
  setSelected: noop,
  toggleDateView: noop,
  date: new Date(),
};
export default DecadeView;
