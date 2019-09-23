import React from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';
import Pagination from '../../../Pagination/PaginationWrapper';
import TableBody from './TableBody';

const Table = ({
  columns,
  rows,
  bodyMessage,
  children,
  isPaginated,
  itemCount,
  pagination,
  onPaginationChange,
  ...props
}) => {
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
      {isPaginated && (
        <div id="pagination">
          <Pagination
            viewType="table"
            itemCount={itemCount}
            pagination={pagination}
            onChange={onPaginationChange}
          />
        </div>
      )}
    </div>
  );
};

Table.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.object).isRequired,
  rows: PropTypes.arrayOf(PropTypes.object).isRequired,
  bodyMessage: PropTypes.node,
  children: PropTypes.node,
  isPaginated: PropTypes.bool,
  itemCount: PropTypes.number,
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }),
  onPaginationChange: PropTypes.func,
};

Table.defaultProps = {
  bodyMessage: undefined,
  children: undefined,
  isPaginated: false,
  itemCount: 0,
  pagination: {},
  onPaginationChange: undefined,
};

export default Table;
