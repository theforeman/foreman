import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import URI from '@theforeman/vendor/urijs';
import { MenuItem } from '@theforeman/vendor/patternfly-react';
import EllipisWithTooltip from '@theforeman/vendor/react-ellipsis-with-tooltip';

const Bookmark = ({ text, query }) => {
  const handleClick = e => {
    e.preventDefault();
    const uri = new URI(window.location.href);

    uri.setSearch('search', query.trim());
    window.Turbolinks.visit(uri.toString());
  };

  return (
    <MenuItem onClick={handleClick}>
      <EllipisWithTooltip>{text}</EllipisWithTooltip>
    </MenuItem>
  );
};

Bookmark.propTypes = {
  text: PropTypes.string.isRequired,
  query: PropTypes.string.isRequired,
};

export default Bookmark;
