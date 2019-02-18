import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import EllipsisWithTooltip from '@theforeman/vendor/react-ellipsis-with-tooltip';

const SearchLink = ({ url, title, id, textValue }) => {
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
};

SearchLink.propTypes = {
  url: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
  title: PropTypes.string,
  textValue: PropTypes.string,
};

SearchLink.defaultProps = {
  title: undefined,
  textValue: '',
};

export default SearchLink;
