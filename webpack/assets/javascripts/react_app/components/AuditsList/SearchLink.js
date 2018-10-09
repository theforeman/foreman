import React from 'react';
import PropTypes from 'prop-types';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';

class SearchLink extends React.Component {
  render() {
    const { url, title, id, textValue } = this.props;

    const linkProps = {
      href: url,
      title,
      id: `resource-link-${id}`,
    };

    return (
      <EllipsisWithTooltip>
        <a {...linkProps}>{textValue}</a>
      </EllipsisWithTooltip>
    );
  }
}

SearchLink.propTypes = {
  url: PropTypes.string,
  title: PropTypes.string,
  id: PropTypes.number,
  textValue: PropTypes.string,
};

export default SearchLink;
