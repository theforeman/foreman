import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

const Day = ({ day, setSelected, classNamesArray }) => {
  const date = day.getDate();
  return (
    <td
      className={classNames('day', classNamesArray)}
      data-day={date}
      onClick={() => {
        setSelected(day);
      }}
    >
      {date}
    </td>
  );
};

Day.propTypes = {
  day: PropTypes.instanceOf(Date).isRequired,
  classNamesArray: PropTypes.object,
  setSelected: PropTypes.func,
};

Day.defaultProps = {
  setSelected: null,
  classNamesArray: [],
};
export default Day;
