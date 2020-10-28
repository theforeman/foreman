import React from 'react';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';

const AuthSourceTable = ({ cells, rows, actions }) => {
  return (
    <Table
      aria-label="Simple Table"
      cells={cells}
      rows={rows}
      actions={actions}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
};

export default AuthSourceTable;
