import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';
import { timezone } from '../../../common/i18n';

class LongDateTime extends React.Component {
  render() {
    if (this.props.data.date) {
      const { date } = this.props.data;
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
            year="numeric"
            timeZone={timezone} />
        </span>
      );
    }
    return (
      <span>{this.props.data.default}</span>
    );
  }
}

LongDateTime.contextTypes = {
  intl: intlShape,
};

LongDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    default: PropTypes.string,
  }),
};

export default LongDateTime;
