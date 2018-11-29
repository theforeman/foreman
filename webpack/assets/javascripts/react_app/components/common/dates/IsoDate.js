import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';

const IsoDate = (props, context) => {
  const { date, defaultValue } = props;
  if (date) {
    const title = context.intl.formatRelative(date);

    return (
      <span title={title}>
        <FormattedDate
          value={date}
          day="2-digit"
          month="2-digit"
          year="numeric"
        />
      </span>
    );
  }
  return <span>{defaultValue}</span>;
};

IsoDate.contextTypes = {
  intl: intlShape,
};

IsoDate.propTypes = {
  date: PropTypes.any,
  defaultValue: PropTypes.string,
};

IsoDate.defaultProps = {
  date: null,
  defaultValue: '',
};

export default IsoDate;
