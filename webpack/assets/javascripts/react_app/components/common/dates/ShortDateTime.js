import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';
import { timezone } from '../../../common/i18n';

class ShortDateTime extends React.Component {
  render() {
    if (this.props.data.date) {
      const { date } = this.props.data;
      const title = this.context.intl.formatRelative(date);
      const seconds = this.props.data.seconds ? '2-digit' : undefined;

      return (
        <span title={title}>
          <FormattedDate value={date}
            day="2-digit"
            month="short"
            hour="2-digit"
            second={seconds}
            minute="2-digit"
            timeZone={timezone} />
        </span>
      );
    }
    return (
      <span>{this.props.data.default}</span>
    );
  }
}

ShortDateTime.contextTypes = {
  intl: intlShape,
};

ShortDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    default: PropTypes.string,
  }),
};

export default ShortDateTime;
