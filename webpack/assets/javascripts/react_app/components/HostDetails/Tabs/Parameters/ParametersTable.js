import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { TableComposable, Thead, Tbody, Tr, Th } from '@patternfly/react-table';
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Button,
  Spinner,
  SearchInput,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';
import { ParametersTableRow } from './TableRow';
import { columnNames, HOST_PARAM } from './ParametersConstants';
import Pagination from '../../../Pagination';
import { useForemanSettings } from '../../../../Root/Context/ForemanContext';
import './Parameters.scss';
import { STATUS } from '../../../../constants';
import { useTableSort } from '../../../PF4/Helpers/useTableSort';

export const ParametersTable = ({
  status,
  hostId,
  allParameters,
  editHostsPermission,
}) => {
  const [editingRow, setEditingRow] = useState(-1);
  const { perPage: settingsPerPage } = useForemanSettings() || {};
  const [page, setPage] = useState(1);
  const [perPage, setPerPage] = useState(settingsPerPage);
  const [showNewRow, setShowNewRow] = useState(false);
  const [search, setSearch] = useState('');

  const { pfSortParams, activeSortDirection } = useTableSort({
    allColumns: Object.values(columnNames),
    columnsToSortParams: {
      [columnNames.name]: 'name',
    },
    initialSortColumnName: 'Name',
    onSort: (_event, index, direction) => {
      setParameters(sortedParams(direction).slice(0, perPage));
      setPage(1);
    },
  });

  const sortedParams = (
    direction = activeSortDirection,
    params = allParameters
  ) =>
    [...params].sort((a, b) => {
      if (direction === 'asc') {
        return a.name.localeCompare(b.name);
      }
      return b.name.localeCompare(a.name);
    });
  const [parameters, setParameters] = useState(
    sortedParams().slice(0, settingsPerPage)
  );
  const onPaginationChange = ({ page: newPage, per_page: newPerPage }) => {
    setPage(newPage);
    setPerPage(newPerPage);
    setParameters(
      sortedParams().slice((newPage - 1) * newPerPage, newPage * newPerPage)
    );
  };
  const onSearch = newSearch => {
    setSearch(newSearch);
    setParameters(
      sortedParams(
        activeSortDirection,
        allParameters.filter(param => param.name.includes(newSearch))
      ).slice(0, settingsPerPage)
    );
  };
  return (
    <>
      <Toolbar ouiaId="parameters-table-toolbar">
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInput
              placeholder={__('Find by name')}
              value={search}
              onChange={setSearch}
              onSearch={onSearch}
              onClear={() => {
                setSearch('');
                onSearch('');
              }}
            />
          </ToolbarItem>
          <ToolbarItem>
            {editHostsPermission && (
              <Button
                ouiaId="add-parameter-btn"
                onClick={() => setShowNewRow(true)}
              >
                {__('Add parameter')}
              </Button>
            )}
          </ToolbarItem>
          <ToolbarItem>
            {status === STATUS.PENDING && <Spinner loading size="sm" />}
          </ToolbarItem>
          <ToolbarItem variant="pagination">
            <Pagination
              variant="top"
              itemCount={allParameters.length}
              onChange={onPaginationChange}
              updateParamsByUrl={false}
              page={page}
              perPage={perPage}
            />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      <TableComposable
        ouiaId="parameters-table"
        id="parameters-table"
        aria-label="Parameters table"
        variant="compact"
      >
        <Thead>
          <Tr ouiaId="parameters-table-header">
            <Th sort={pfSortParams(columnNames.name)}>{columnNames.name}</Th>
            <Th>{columnNames.type}</Th>
            <Th>{columnNames.value}</Th>
            <Th>{columnNames.source}</Th>
            <Th />
          </Tr>
        </Thead>
        <Tbody>
          {showNewRow && (
            <ParametersTableRow
              key="new-parameter"
              param={{
                associated_type: HOST_PARAM,
                name: '',
                parameter_type: 'string',
                value: '',
                id: -1,
                'hidden_value?': false,
              }}
              rowIndex={-2}
              editingRow={editingRow}
              setEditingRow={() => setShowNewRow(false)}
              hostId={hostId}
              editHostsPermission={editHostsPermission}
              isNew
            />
          )}
          {parameters.map((param, rowIndex) => (
            <ParametersTableRow
              key={`${rowIndex}-${param.name}`}
              param={param}
              rowIndex={rowIndex}
              editingRow={editingRow}
              setEditingRow={setEditingRow}
              hostId={hostId}
              editHostsPermission={editHostsPermission}
            />
          ))}
        </Tbody>
      </TableComposable>
      <Pagination
        variant="bottom"
        itemCount={allParameters.length}
        onChange={onPaginationChange}
        updateParamsByUrl={false}
        page={page}
        perPage={perPage}
      />
    </>
  );
};

ParametersTable.propTypes = {
  status: PropTypes.string,
  hostId: PropTypes.number.isRequired,
  allParameters: PropTypes.array,
  editHostsPermission: PropTypes.bool.isRequired,
};

ParametersTable.defaultProps = {
  status: STATUS.PENDING,
  allParameters: [],
};
