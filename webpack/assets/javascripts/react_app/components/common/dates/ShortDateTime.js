import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';

class ShortDateTime extends React.Component {
  render() {
    const { date, defaultValue, seconds } = this.props.data;
    if (date) {
      const title = this.context.intl.formatRelative(date);
      const secondsFormat = seconds ? '2-digit' : undefined;

      return (
        <span title={title}>
          <FormattedDate value={date}
            day="2-digit"
            month="short"
            hour="2-digit"
            second={secondsFormat}
            minute="2-digit" />
        </span>
      );
    }
    return (
      <span>{defaultValue}</span>
    );
  }
}

ShortDateTime.contextTypes = {
  intl: intlShape,
};

ShortDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    defaultValue: PropTypes.string,
    seconds: PropTypes.bool,
  }),
};

export default ShortDateTime;
