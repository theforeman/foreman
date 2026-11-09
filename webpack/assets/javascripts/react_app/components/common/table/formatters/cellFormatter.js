import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';
import { deprecate } from '../../../../common/DeprecationService';

const TableCell = ({ children }) => {
  useEffect(() => {
    deprecate(
      'table/formatters/cellFormatter',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  return <PfTable.Cell>{children}</PfTable.Cell>;
};

TableCell.propTypes = {
  children: PropTypes.node,
};

TableCell.defaultProps = {
  children: null,
};

export default value => <TableCell>{value}</TableCell>;
