import React from 'react';
import PropTypes from 'prop-types';

const SortableHeader = ({ onClick, children, sortOrder }) => (
  <a onClick={onClick}>
    {sortOrder && <i className={`fa fa-sort-${sortOrder}`} />}
    {children}
  </a>
);

SortableHeader.propTypes = {
  onClick: PropTypes.func.isRequired,
  children: PropTypes.node.isRequired,
  sortOrder: PropTypes.oneOf(['asc', 'desc', null]),
};

SortableHeader.defaultProps = {
  sortOrder: null,
};

export default SortableHeader;
