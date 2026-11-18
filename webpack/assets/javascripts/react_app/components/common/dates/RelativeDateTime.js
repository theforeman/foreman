import React from 'react';
import PropTypes from 'prop-types';
import { intlShape } from 'react-intl';
import { isoCompatibleDate } from '../../../common/helpers';

const RelativeDateTime = (props, context) => {
  const { date, defaultValue, children } = props;
  if (date) {
    const isoDate = isoCompatibleDate(date);
    const title = context.intl.formatDate(isoDate, {
      day: '2-digit',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
      year: 'numeric',
    });

    const relativeTime = context.intl.formatRelative(isoDate, {
      style: 'numeric',
    });

    return (
      <span title={title}>
        {children ? children(relativeTime) : relativeTime}
      </span>
    );
  }

  return <span>{defaultValue}</span>;
};

RelativeDateTime.contextTypes = {
  intl: intlShape,
};

RelativeDateTime.propTypes = {
  date: PropTypes.any,
  defaultValue: PropTypes.node,
  children: PropTypes.func,
};

RelativeDateTime.defaultProps = {
  date: null,
  defaultValue: '',
  children: undefined,
};

export default RelativeDateTime;
