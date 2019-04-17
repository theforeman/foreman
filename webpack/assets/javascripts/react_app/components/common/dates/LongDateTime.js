import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';
import { isoCompatibleDate } from '../../../common/helpers';

const LongDateTime = (props, context) => {
  const { date, defaultValue } = props;
  if (date) {
    const isoDate = isoCompatibleDate(date);
    const title = context.intl.formatRelative(isoDate);
    const seconds = props.seconds ? '2-digit' : undefined;

    return (
      <span title={title}>
        <FormattedDate
          value={isoDate}
          day="2-digit"
          month="long"
          hour="2-digit"
          minute="2-digit"
          second={seconds}
          year="numeric"
        />
      </span>
    );
  }
  return <span>{defaultValue}</span>;
};

LongDateTime.contextTypes = {
  intl: intlShape,
};

LongDateTime.propTypes = {
  date: PropTypes.any,
  defaultValue: PropTypes.string,
  seconds: PropTypes.bool,
};

LongDateTime.defaultProps = {
  date: null,
  defaultValue: '',
  seconds: false,
};

export default LongDateTime;
