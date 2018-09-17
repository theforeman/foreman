import React from 'react';
import URI from 'urijs';
import { MenuItem } from 'patternfly-react';
import EllipisWithTooltip from 'react-ellipsis-with-tooltip';

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

export default Bookmark;
