import React from 'react';
import PropTypes from 'prop-types';
import { MenuItem } from 'patternfly-react';
import EllipisWithTooltip from 'react-ellipsis-with-tooltip';

const Bookmark = ({ text, query, onClick }) => (
  <MenuItem onClick={() => onClick(query)}>
    <EllipisWithTooltip>{text}</EllipisWithTooltip>
  </MenuItem>
);

Bookmark.propTypes = {
  onClick: PropTypes.func.isRequired,
  text: PropTypes.string.isRequired,
  query: PropTypes.string.isRequired,
};

export default Bookmark;
