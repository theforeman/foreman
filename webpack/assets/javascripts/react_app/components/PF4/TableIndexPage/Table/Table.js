import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  TableComposable,
  Thead,
  Tr,
  Th,
  Tbody,
  Td,
  ActionsColumn,
} from '@patternfly/react-table';
import { translate as __ } from '../../../../common/I18n';
import { useTableSort } from '../../Helpers/useTableSort';
import Pagination from '../../../Pagination';
import { DeleteModal } from './DeleteModal';
import EmptyPage from '../../../../routes/common/EmptyPage';

export const Table = ({
  columns,
  errorMessage,
  getActions,
  isDeleteable,
  itemCount,
  params,
  refreshData,
  results,
  setParams,
  url,
  isPending,
  isEmbedded,
}) => {
  const columnsToSortParams = {};
  Object.keys(columns).forEach(key => {
    if (columns[key].isSorted) {
      columnsToSortParams[columns[key].title] = key;
    }
  });
  const columnNames = {};
  Object.keys(columns).forEach(key => {
    columnNames[key] = columns[key].title;
  });
  const onSort = (_event, index, direction) => {
    setParams({
      ...params,
      order: `${Object.keys(columns)[index]} ${direction}`,
    });
  };
  const onPagination = newPagination => {
    setParams({ ...params, ...newPagination });
  };
  const { pfSortParams } = useTableSort({
    allColumns: Object.keys(columns).map(k => columns[k].title),
    columnsToSortParams,
    onSort,
  });
  const [selectedItem, setSelectedItem] = useState({});
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const onDeleteClick = ({ id, name }) => {
    setSelectedItem({ id, name });
    setDeleteModalOpen(true);
  };
  const actions = ({ can_delete: canDelete, id, name, ...item }) =>
    [
      isDeleteable && {
        title: __('Delete'),
        onClick: () => onDeleteClick({ id, name }),
        isDisabled: !canDelete,
      },
      getActions && getActions({ id, name, ...item }),
    ].filter(Boolean);
  const columnNamesKeys = Object.keys(columns);
  return (
    <>
      <DeleteModal
        isModalOpen={deleteModalOpen}
        setIsModalOpen={setDeleteModalOpen}
        selectedItem={selectedItem}
        url={url}
        refreshData={refreshData}
      />
      <TableComposable variant="compact" ouiaId="table">
        <Thead>
          <Tr ouiaId="table-header">
            {columnNamesKeys.map(k => (
              <Th
                key={k}
                sort={
                  Object.values(columnsToSortParams).includes(k) &&
                  pfSortParams(columnNames[k])
                }
              >
                {columnNames[k]}
              </Th>
            ))}
          </Tr>
        </Thead>
        <Tbody>
          {isPending && results.length === 0 && (
            <Tr ouiaId="table-loading">
              <Td colSpan={100}>
                <EmptyPage
                  message={{
                    type: 'empty',
                    text: __('Loading...'),
                  }}
                />
              </Td>
            </Tr>
          )}
          {!isPending && !errorMessage && results.length === 0 && (
            <Tr ouiaId="table-empty">
              <Td colSpan={100}>
                <EmptyPage />
              </Td>
            </Tr>
          )}
          {errorMessage && (
            <Tr ouiaId="table-error">
              <Td colSpan={100}>
                <EmptyPage message={{ type: 'error', text: errorMessage }} />
              </Td>
            </Tr>
          )}
          {results.map((result, rowIndex) => (
            <Tr key={rowIndex} ouiaId={`table-row-${rowIndex}`}>
              {columnNamesKeys.map(k => (
                <Td key={k} dataLabel={columnNames[k]}>
                  {columns[k].wrapper ? columns[k].wrapper(result) : result[k]}
                </Td>
              ))}
              <Td isActionCell>
                {actions ? <ActionsColumn items={actions(result)} /> : null}
              </Td>
            </Tr>
          ))}
        </Tbody>
      </TableComposable>
      {results.length > 0 && !errorMessage && (
        <Pagination
          page={params.page}
          perPage={params.perPage}
          itemCount={itemCount}
          onChange={onPagination}
          updateParamsByUrl={!isEmbedded}
        />
      )}
    </>
  );
};

Table.propTypes = {
  columns: PropTypes.object.isRequired,
  params: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
    order: PropTypes.string,
  }).isRequired,
  errorMessage: PropTypes.string,
  getActions: PropTypes.func,
  isDeleteable: PropTypes.bool,
  itemCount: PropTypes.number,
  refreshData: PropTypes.func.isRequired,
  results: PropTypes.array,
  setParams: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  isPending: PropTypes.bool.isRequired,
  isEmbedded: PropTypes.bool,
};

Table.defaultProps = {
  errorMessage: null,
  isDeleteable: false,
  itemCount: 0,
  getActions: null,
  results: [],
  isEmbedded: false,
};
