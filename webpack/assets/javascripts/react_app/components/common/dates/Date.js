import React from 'react';
import PropTypes from 'prop-types';
import { FormattedDate, intlShape } from 'react-intl';
import { timezone } from '../../../common/i18n';

class Date extends React.Component {
  render() {
    if (this.props.data.date) {
      const { date } = this.props.data;
      const title = this.context.intl.formatRelative(date);

      return (
        <span title={title}>
          <FormattedDate value={date}
            day="2-digit"
            month="2-digit"
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

Date.contextTypes = {
  intl: intlShape,
};

Date.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    default: PropTypes.string,
  }),
};

export default Date;
