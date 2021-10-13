import React from 'react';
import PropTypes from 'prop-types';
import { noop } from '../../../../common/helpers';

export const DecadeViewTable = ({
  yearArray,
  selectedYear,
  setSelectedYear,
}) => (
  <tbody>
    <tr>
      <td colSpan="7">
        {yearArray.map((year) => (
          <span
            onClick={() => setSelectedYear(year)}
            className={`year ${year === selectedYear ? 'active' : ''}`}
            key={year}
          >
            {year}
          </span>
        ))}
      </td>
    </tr>
  </tbody>
);

DecadeViewTable.propTypes = {
  yearArray: PropTypes.array,
  selectedYear: PropTypes.number,
  setSelectedYear: PropTypes.func,
};
DecadeViewTable.defaultProps = {
  yearArray: [],
  selectedYear: new Date().getFullYear(),
  setSelectedYear: noop,
};

export default DecadeViewTable;
