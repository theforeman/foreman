import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { deprecate } from '../../../../common/DeprecationService';

const SortableHeader = ({ onClick, children, sortOrder }) => {
  useEffect(() => {
    deprecate(
      'table/components/SortableHeader',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  return (
    <a onClick={onClick}>
      {sortOrder && <i className={`fa fa-sort-${sortOrder}`} />}
      {children}
    </a>
  );
};

SortableHeader.propTypes = {
  onClick: PropTypes.func.isRequired,
  children: PropTypes.node.isRequired,
  sortOrder: PropTypes.oneOf(['asc', 'desc', null]),
};

SortableHeader.defaultProps = {
  sortOrder: null,
};

export default SortableHeader;
