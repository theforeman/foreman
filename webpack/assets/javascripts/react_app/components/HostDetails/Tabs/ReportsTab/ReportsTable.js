import React from 'react';
import PropTypes from 'prop-types';
import {
  TableComposable,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
} from '@patternfly/react-table';
import { Spinner } from '@patternfly/react-core';
import { SearchIcon, ExclamationCircleIcon } from '@patternfly/react-icons';
import { STATUS } from '../../../../constants';
import EmptyState from '../../../common/EmptyState';
import { translate as __ } from '../../../../common/I18n';
import { getColumns } from './helpers';

const ReportsTable = ({ reports, status, fetchReports, error, origin }) => {
  const columns = getColumns(fetchReports, origin);
  let tableBody = null;
  let tableHead = null;
  let emptyState = null;

  if (status === STATUS.RESOLVED) {
    if (reports.length) {
      tableHead = (
        <Thead>
          <Tr ouiaId="row-header">
            {columns.map(({ width, title }, columnIndex) => (
              <Th key={columnIndex} width={width}>
                {title}
              </Th>
            ))}
          </Tr>
        </Thead>
      );
      tableBody = (
        <Tbody>
          {reports.map((row, rowIndex) => (
            <Tr key={rowIndex} ouiaId={`row-${rowIndex}`}>
              {columns.map(({ title, formatter }, cellIndex) => (
                <Td key={`${rowIndex}_${cellIndex}`} dataLabel={title}>
                  {formatter(row)}
                </Td>
              ))}
            </Tr>
          ))}
        </Tbody>
      );
    } else {
      emptyState = (
        <EmptyState icon={<SearchIcon />} header={__('No results found')} />
      );
    }
  } else if (status === STATUS.ERROR) {
    emptyState = (
      <EmptyState
        icon={
          <ExclamationCircleIcon color="var(--pf-global--palette--red-200)" />
        }
        header={__('Something went wrong')}
        description={error}
      />
    );
  } else if (status === STATUS.PENDING) {
    emptyState = <EmptyState icon={<Spinner />} header={__('Loading')} />;
  }

  return (
    <React.Fragment>
      <TableComposable
        aria-label="Reports table"
        ouiaId="reports-table"
        variant="compact"
      >
        {tableHead}
        {tableBody}
      </TableComposable>
      {emptyState}
    </React.Fragment>
  );
};

ReportsTable.propTypes = {
  reports: PropTypes.array,
  status: PropTypes.string,
  error: PropTypes.string,
  origin: PropTypes.string,
  fetchReports: PropTypes.func.isRequired,
};

ReportsTable.defaultProps = {
  reports: [],
  status: null,
  error: null,
  origin: null,
};

export default ReportsTable;
