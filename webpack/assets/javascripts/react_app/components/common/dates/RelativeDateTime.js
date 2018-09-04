import React from 'react';
import PropTypes from 'prop-types';
import { FormattedRelative, intlShape } from 'react-intl';
import { timezone } from '../../../common/i18n';

class RelativeDateTime extends React.Component {
  render() {
    const { date, defaultValue } = this.props.data;
    if (date) {
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
      <span>{defaultValue}</span>
    );
  }
}

RelativeDateTime.contextTypes = {
  intl: intlShape,
};

RelativeDateTime.propTypes = {
  data: PropTypes.shape({
    date: PropTypes.any,
    defaultValue: PropTypes.string,
  }),
};

export default RelativeDateTime;
