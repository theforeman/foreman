import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';

class LongDateTime extends React.Component {
  render() {
    const { date, defaultValue } = this.props.data;
    if (date) {
      const title = this.context.intl.formatRelative(date);
      const seconds = this.props.data.seconds ? '2-digit' : undefined;

      return (
        <span title={title}>
          <FormattedDate value={date}
            day="2-digit"
            month="long"
            hour="2-digit"
            minute="2-digit"
            second={seconds}
            year="numeric" />
        </span>
      );
    }
    return (
      <span>{defaultValue}</span>
    );
  }
}

LongDateTime.contextTypes = {
  intl: intlShape,
};

LongDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    defaultValue: PropTypes.string,
  }),
};

export default LongDateTime;
