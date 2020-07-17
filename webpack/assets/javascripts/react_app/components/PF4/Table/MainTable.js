import React from 'react';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import PropTypes from 'prop-types';

import { STATUS } from '../../../constants';
import TableEmptyState from './TableEmptyState';
import Loading from '../../Loading';

const MainTable = ({
  status,
  cells,
  rows,
  error,
  emptyContentTitle,
  emptyContentBody,
  emptySearchTitle,
  emptySearchBody,
  searchIsActive,
  activeFilters,
  ...extraTableProps
}) => {
  const isFiltering = activeFilters || searchIsActive;
  if (status === STATUS.PENDING) return <Loading showText={false} />;
  // Can we display the error message?
  if (status === STATUS.ERROR) return <TableEmptyState error={error} />;
  if (status === STATUS.RESOLVED && isFiltering && rows.length === 0) {
    return (
      <TableEmptyState title={emptySearchTitle} body={emptySearchBody} search />
    );
  }
  if (status === STATUS.RESOLVED && rows && rows.length === 0) {
    return (
      <TableEmptyState title={emptyContentTitle} body={emptyContentBody} />
    );
  }

  const tableProps = { cells, rows, ...extraTableProps };
  return (
    <Table
      aria-label="Content View Table"
      className="katello-pf4-table"
      {...tableProps}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
};

MainTable.propTypes = {
  status: PropTypes.string.isRequired,
  cells: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.shape({}), PropTypes.string])
  ).isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})),
  error: PropTypes.oneOfType([PropTypes.shape({}), PropTypes.string]),
  emptyContentTitle: PropTypes.string.isRequired,
  emptyContentBody: PropTypes.string.isRequired,
  emptySearchTitle: PropTypes.string.isRequired,
  emptySearchBody: PropTypes.string.isRequired,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.bool,
};

MainTable.defaultProps = {
  rows: null,
  error: null,
  searchIsActive: false,
  activeFilters: false,
};

export default MainTable;
