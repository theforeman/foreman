import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';
import { isoCompatibleDate } from '../../../common/helpers';

const ShortDateTime = (props, context) => {
  const { date, defaultValue, seconds } = props;
  if (date) {
    const isoDate = isoCompatibleDate(date);
    const title = props.showRelativeTimeTooltip
      ? context.intl.formatRelative(isoDate)
      : undefined;
    const secondsFormat = seconds ? '2-digit' : undefined;
    return (
      <span title={title}>
        <FormattedDate
          value={isoDate}
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
  showRelativeTimeTooltip: PropTypes.bool,
};

ShortDateTime.defaultProps = {
  date: null,
  defaultValue: '',
  seconds: false,
  showRelativeTimeTooltip: false,
};

export default ShortDateTime;
