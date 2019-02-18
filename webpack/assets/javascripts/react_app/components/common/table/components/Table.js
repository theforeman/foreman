import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Table as PfTable } from '@theforeman/vendor/patternfly-react';
import TableBody from './TableBody';

const Table = ({ columns, rows, bodyMessage, children, ...props }) => {
  const body = children || [
    <PfTable.Header key="header" />,
    <TableBody
      key="body"
      columns={columns}
      rows={rows}
      message={bodyMessage}
      rowKey="id"
    />,
  ];

  return (
    <div>
      <PfTable.PfProvider
        columns={columns}
        className="table-fixed"
        striped
        bordered
        hover
        {...props}
      >
        {body}
      </PfTable.PfProvider>
    </div>
  );
};

Table.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.object).isRequired,
  rows: PropTypes.arrayOf(PropTypes.object).isRequired,
  bodyMessage: PropTypes.node,
  children: PropTypes.node,
};

Table.defaultProps = {
  bodyMessage: undefined,
  children: undefined,
};

export default Table;
