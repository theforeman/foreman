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
import {
  EmptyState,
  EmptyStateIcon,
  Spinner,
  Title,
  Grid,
} from '@patternfly/react-core';
import { SearchIcon, ExclamationCircleIcon } from '@patternfly/react-icons';
import { STATUS } from '../../../../constants';
import { translate as __ } from '../../../../common/I18n';
import { getColumns } from './helpers';

const ReportsTable = ({ reports, status, fetchReports }) => {
  const columns = getColumns(fetchReports);
  let tableBody = null;
  let tableHead = null;
  let emptyState = null;

  if (status === STATUS.RESOLVED) {
    if (reports.length) {
      tableHead = (
        <Thead>
          <Tr>
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
            <Tr key={rowIndex}>
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
        <Grid>
          <EmptyState>
            <EmptyStateIcon icon={SearchIcon} />
            <Title size="lg" headingLevel="h4">
              {__('No results found')}
            </Title>
          </EmptyState>
        </Grid>
      );
    }
  } else if (status === STATUS.FAILURE) {
    emptyState = (
      <Grid>
        <EmptyState>
          <EmptyStateIcon
            icon={
              <ExclamationCircleIcon color="var(--pf-global--palette--red-200)" />
            }
          />
          <Title size="lg" headingLevel="h4">
            {__('Something went wrong')}
          </Title>
        </EmptyState>
      </Grid>
    );
  } else if (status === STATUS.PENDING) {
    emptyState = (
      <Grid>
        <EmptyState>
          <EmptyStateIcon variant="container" component={Spinner} />
          <Title size="lg" headingLevel="h4">
            {__('Loading')}
          </Title>
        </EmptyState>
      </Grid>
    );
  }

  return (
    <React.Fragment>
      <TableComposable aria-label="Reports table" variant="compact">
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
  fetchReports: PropTypes.func.isRequired,
};

ReportsTable.defaultProps = {
  reports: [],
  status: null,
};

export default ReportsTable;
