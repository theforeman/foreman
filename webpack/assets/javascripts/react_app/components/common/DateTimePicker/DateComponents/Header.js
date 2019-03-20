import React from 'react';
import PropTypes from 'prop-types';
import { Icon } from 'patternfly-react';
import { YEAR } from './DateConstants';
import { getWeekArray } from './HeaderHelpers';

const Header = ({
  getNextMonth,
  getPrevMonth,
  toggleDateView,
  weekStartsOn,
  date,
  locale,
}) => {
  date = new Date(date);
  const month = Intl.DateTimeFormat(locale, {
    month: 'long',
  }).format(date);
  const year = date.getFullYear();
  const daysOfTheWeek = getWeekArray(weekStartsOn);
  return (
    <thead>
      <tr>
        <th className="prev" onClick={getPrevMonth}>
          <Icon type="fa" name="angle-left" />
        </th>
        <th
          className="picker-switch"
          colSpan="5"
          onClick={() => toggleDateView(YEAR)}
        >
          {month} {year}
        </th>
        <th className="next" onClick={getNextMonth}>
          <Icon type="fa" name="angle-right" />
        </th>
      </tr>
      <tr>
        {daysOfTheWeek.map((day, idx) => (
          <th key={idx} className="dow">
            {day}
          </th>
        ))}
      </tr>
    </thead>
  );
};

Header.propTypes = {
  date: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  getPrevMonth: PropTypes.func,
  getNextMonth: PropTypes.func,
  toggleDateView: PropTypes.func,
  locale: PropTypes.string,
  weekStartsOn: PropTypes.number,
};

Header.defaultProps = {
  date: new Date(),
  getPrevMonth: null,
  getNextMonth: null,
  toggleDateView: null,
  locale: 'en-US',
  weekStartsOn: 1,
};
export default Header;
