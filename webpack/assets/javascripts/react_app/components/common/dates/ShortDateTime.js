import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';

const ShortDateTime = (props, context) => {
  const { date, defaultValue, seconds } = props;
  if (date) {
    const title = context.intl.formatRelative(date);
    const secondsFormat = seconds ? '2-digit' : undefined;

    return (
      <span title={title}>
        <FormattedDate
          value={date}
          day="2-digit"
          month="short"
          hour="2-digit"
          second={secondsFormat}
          minute="2-digit"
        />
      </span>
    );
  }
  return <span>{defaultValue}</span>;
};

ShortDateTime.contextTypes = {
  intl: intlShape,
};

ShortDateTime.propTypes = {
  date: PropTypes.any,
  defaultValue: PropTypes.string,
  seconds: PropTypes.bool,
};

ShortDateTime.defaultProps = {
  date: null,
  defaultValue: '',
  seconds: false,
};

export default ShortDateTime;
