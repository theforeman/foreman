import React from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';

import TableBodyMessage from './TableBodyMessage';

const TableBody = ({ columns, rows, message, ...props }) => {
  if (message) {
    return (
      <TableBodyMessage colSpan={columns.length}>{message}</TableBodyMessage>
    );
  }

  return (
    <PfTable.Body rows={rows} rowKey={({ rowIndex }) => rowIndex} {...props} />
  );
};

TableBody.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.object).isRequired,
  rows: PropTypes.arrayOf(PropTypes.object).isRequired,
  message: PropTypes.node,
};

TableBody.defaultProps = {
  message: undefined,
};

export default TableBody;
