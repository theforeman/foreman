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
import { noop } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import { useTableSort } from '../../Helpers/useTableSort';
import Pagination from '../../../Pagination';
import { DeleteModal } from './DeleteModal';
import EmptyPage from '../../../../routes/common/EmptyPage';
import { getColumnHelpers } from './helpers';

export const Table = ({
  columns,
  customEmptyState,
  emptyAction,
  emptyMessage,
  errorMessage,
  getActions,
  isDeleteable,
  itemCount,
  selectOne,
  isSelected,
  params,
  refreshData,
  results,
  setParams,
  url,
  isPending,
  isEmbedded,
  showCheckboxes,
  rowSelectTd,
  idColumn,
  children,
  bottomPagination,
  childrenOutsideTbody, // Expendable table rows are each a Tbody so they cant be inside the Tbody
}) => {
  const onPagination = newPagination => {
    setParams({ ...params, ...newPagination });
  };
  if (!bottomPagination)
    bottomPagination = (
      <Pagination
        key="table-bottom-pagination"
        page={params.page}
        perPage={params.perPage}
        itemCount={itemCount}
        onChange={onPagination}
        updateParamsByUrl={!isEmbedded}
      />
    );
  const columnsToSortParams = {};
  Object.keys(columns).forEach(key => {
    if (columns[key].isSorted) {
      columnsToSortParams[columns[key].title] = key;
    }
  });
  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);
  const onSort = (_event, index, direction) => {
    setParams({
      ...params,
      order: `${Object.keys(columns)[index]} ${direction}`,
    });
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
  const actions = ({
    can_delete: canDelete,
    can_edit: canEdit,
    id,
    name,
    ...item
  }) =>
    [
      isDeleteable && {
        title: __('Delete'),
        onClick: () => onDeleteClick({ id, name }),
        isDisabled: !canDelete,
      },
      ...((getActions &&
        getActions({ id, name, canDelete, canEdit, ...item })) ??
        []),
    ].filter(Boolean);
  const RowSelectTd = rowSelectTd;
  return (
    <>
      <DeleteModal
        isModalOpen={deleteModalOpen}
        setIsModalOpen={setDeleteModalOpen}
        selectedItem={selectedItem}
        url={url}
        refreshData={refreshData}
      />
      <TableComposable variant="compact" ouiaId="table" isStriped>
        <Thead>
          <Tr ouiaId="table-header">
            {showCheckboxes && <Th key="checkbox-th" />}
            {columnNamesKeys.map(k => (
              <Th
                key={k}
                sort={
                  Object.values(columnsToSortParams).includes(k) &&
                  pfSortParams(keysToColumnNames[k])
                }
              >
                {keysToColumnNames[k]}
              </Th>
            ))}
          </Tr>
        </Thead>
        {childrenOutsideTbody ? children : null}
        <Tbody>
          {isPending && results.length === 0 && (
            <Tr ouiaId="table-loading">
              <Td colSpan={100}>
                <EmptyPage
                  message={{
                    type: 'loading',
                    text: __('Loading...'),
                  }}
                />
              </Td>
            </Tr>
          )}
          {!customEmptyState &&
            !isPending &&
            results.length === 0 &&
            !errorMessage && (
              <Tr ouiaId="table-empty">
                <Td colSpan={100}>
                  <EmptyPage
                    message={{
                      type: 'empty',
                      text: emptyMessage,
                      action: emptyAction,
                    }}
                  />
                </Td>
              </Tr>
            )}
          {customEmptyState}
          {errorMessage && (
            <Tr ouiaId="table-error">
              <Td colSpan={100}>
                <EmptyPage message={{ type: 'error', text: errorMessage }} />
              </Td>
            </Tr>
          )}
          {!childrenOutsideTbody &&
            (children ||
              results.map((result, rowIndex) => {
                const rowActions = actions(result);
                return (
                  <Tr
                    key={rowIndex}
                    ouiaId={`table-row-${rowIndex}`}
                    isHoverable
                  >
                    {showCheckboxes && (
                      <RowSelectTd
                        rowData={result}
                        selectOne={selectOne}
                        isSelected={isSelected}
                        idColumnName={idColumn}
                      />
                    )}
                    {columnNamesKeys.map(k => (
                      <Td key={k} dataLabel={keysToColumnNames[k]}>
                        {columns[k].wrapper
                          ? columns[k].wrapper(result)
                          : result[k]}
                      </Td>
                    ))}
                    <Td isActionCell>
                      {rowActions.length ? (
                        <ActionsColumn items={rowActions} />
                      ) : null}
                    </Td>
                  </Tr>
                );
              }))}
        </Tbody>
      </TableComposable>
      {results.length > 0 && !errorMessage && !emptyMessage && bottomPagination}
    </>
  );
};

Table.propTypes = {
  children: PropTypes.node,
  columns: PropTypes.object.isRequired,
  customEmptyState: PropTypes.object,
  params: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
    order: PropTypes.string,
  }).isRequired,
  emptyAction: PropTypes.object,
  emptyMessage: PropTypes.string,
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
  rowSelectTd: PropTypes.func,
  idColumn: PropTypes.string,
  selectOne: PropTypes.func,
  isSelected: PropTypes.func,
  showCheckboxes: PropTypes.bool,
  bottomPagination: PropTypes.node,
  childrenOutsideTbody: PropTypes.bool,
};

Table.defaultProps = {
  children: null,
  customEmptyState: null,
  emptyAction: null,
  emptyMessage: null,
  errorMessage: null,
  isDeleteable: false,
  itemCount: 0,
  getActions: null,
  results: [],
  isEmbedded: false,
  rowSelectTd: noop,
  idColumn: 'id',
  selectOne: noop,
  isSelected: noop,
  showCheckboxes: false,
  bottomPagination: null,
  childrenOutsideTbody: false,
};
