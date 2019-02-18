import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Table as PfTable } from '@theforeman/vendor/patternfly-react';

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
  message: PropTypes.string,
};

TableBody.defaultProps = {
  message: '',
};

export default TableBody;
