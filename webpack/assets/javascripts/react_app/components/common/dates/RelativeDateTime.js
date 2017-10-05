import React from 'react';
import PropTypes from 'prop-types';
import { FormattedRelative, intlShape } from 'react-intl';
import { timezone } from '../../../common/i18n';

class RelativeDateTime extends React.Component {
  render() {
    if (this.props.data.date) {
      const { date } = this.props.data;
      const title = this.context.intl.formatDate(date, {
        day: '2-digit',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
        year: 'numeric',
        timeZone: timezone,
      });

      return (
        <span title={title}>
          <FormattedRelative value={date} />
        </span>
      );
    }

    return (
      <span>{this.props.data.default}</span>
    );
  }
}

RelativeDateTime.contextTypes = {
  intl: intlShape,
};

RelativeDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    default: PropTypes.string,
  }),
};

export default RelativeDateTime;
