/* eslint-disable camelcase */
/* eslint-disable react-hooks/exhaustive-deps */
import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Pagination, PaginationVariant, Text } from '@patternfly/react-core';
import {
  TableText,
  Table as PF4Table,
  TableHeader,
  TableBody,
  sortable,
  cellWidth,
} from '@patternfly/react-table';

import { useForemanSettings } from '../../../Root/Context/ForemanContext';
import PageLayout from '../../../routes/common/PageLayout/PageLayout';
import { STATUS, getControllerSearchProps } from '../../../constants';
import { translate as __ } from '../../../common/I18n';
import TableEmptyState from './components/Table/components/EmptyState';
import {
  getSortColumnIndex,
  getPerPageOptions,
  getTableAPIKey,
} from './components/Table/TableHelpers';
import ActionsDropdown from './components/ActionsDropdown';
import {
  fetchData,
  onTableSetPage,
  onTablePerPageSelect,
  onTableSort,
} from './components/Table/TableActions';
import PrimaryAction from './components/PrimaryAction';
import EmptyState from '../EmptyState';
import {
  selectAPIErrorMessage,
  selectAPIResponse,
  selectAPIStatus,
} from '../../../redux/API/APISelectors';
import './index.scss';
import { selectQueryParams } from './components/Table/TableSelectors';

const IndexPageTemplate = ({ path, header }) => {
  const [tableRows, setTableRows] = React.useState([]);
  const [tableColumns, setTableColumns] = React.useState([]);
  const { perPage: defaultPerPage } = useForemanSettings();

  const { page, perPage: urlPerPage, query, sortBy, sortOrder } = useSelector(
    selectQueryParams
  );
  const perPage = urlPerPage || defaultPerPage;
  const key = getTableAPIKey(path);
  const {
    rows = [],
    columns = [],
    total_entries = 0,
    global_actions,
    primary_action,
    before_toolbar_content,
    empty_state,
    title,
  } = useSelector(state => selectAPIResponse(state, key));
  const error = useSelector(state => selectAPIErrorMessage(state, key));
  const status = useSelector(state => selectAPIStatus(state, key));

  const dispatch = useDispatch();
  const reloadData = () =>
    dispatch(fetchData(path, { page, perPage, query, sortBy, sortOrder }));

  useEffect(() => {
    reloadData();
  }, []);

  useEffect(() => {
    if (status === STATUS.RESOLVED && rows && columns) {
      const isActions = rows.some(({ actions }) => !!actions);
      setTableRows(handleRows(rows));
      setTableColumns(handleColumns(columns, isActions));
    }
  }, [rows, columns, status]);

  const handleRows = serverRows =>
    serverRows.asMutable({ deep: true }).map(({ cells, actions }) => {
      const nextCells = cells.map(cell => {
        if (typeof cell !== 'object') return cell;
        if (cell.type === 'link') {
          return (
            <TableText>
              <a href={cell.path}>{cell.label}</a>
            </TableText>
          );
        }
        return cell;
      });
      actions &&
        nextCells.push({
          title: <ActionsDropdown actions={actions} reloadData={reloadData} />,
        });

      return { cells: nextCells };
    });

  const handleColumns = (serverColumns, isActions) => {
    const nextColumns = serverColumns.asMutable({ deep: true }).map(colData => {
      if (typeof colData !== 'object') {
        return { title: colData };
      }
      const { sort_by, width, label } = colData;
      const col = { title: label, transforms: [] };
      if (sort_by) {
        col.sortKey = sort_by;
        col.transforms = [sortable];
      }
      if (width) {
        col.transforms = [...col.transforms, cellWidth(width)];
      }
      return col;
    });
    isActions && nextColumns.push(__('Actions'));
    return nextColumns;
  };

  const beforeToolbarComponent = before_toolbar_content && (
    <Text
      className="index-page-description"
      dangerouslySetInnerHTML={{ __html: before_toolbar_content }}
    />
  );

  if (total_entries === 0 && empty_state) {
    return (
      <EmptyState
        {...empty_state}
        description={
          <div
            dangerouslySetInnerHTML={{
              __html: empty_state.description,
            }}
          />
        }
      />
    );
  }

  const paginationProps = variant => ({
    id: `index-page-${variant}-pagination`,
    itemCount: total_entries,
    perPage,
    page,
    variant: PaginationVariant[variant],
    onSetPage: (e, pageNo) => dispatch(onTableSetPage(pageNo, path)),
    onPerPageSelect: (e, perP) => dispatch(onTablePerPageSelect(perP, path)),
    perPageOptions: getPerPageOptions(perPage, defaultPerPage),
  });

  return (
    <PageLayout
      className="index_page_template"
      searchable
      searchQuery={query}
      searchProps={getControllerSearchProps(path)}
      onSearch={nextQuery =>
        dispatch(fetchData(path, { query: nextQuery, page: 1 }))
      }
      header={header}
      title={title}
      beforeToolbarComponent={beforeToolbarComponent}
      toolbarButtons={
        <>
          <PrimaryAction {...primary_action} />
          <ActionsDropdown actions={global_actions} />
          <Pagination {...paginationProps('top')} />
        </>
      }
    >
      <PF4Table
        sortBy={{
          index: getSortColumnIndex(tableColumns, sortBy),
          direction: sortOrder,
        }}
        onSort={(e, index, direction) =>
          dispatch(onTableSort(index, direction, tableColumns, path))
        }
        rows={tableRows}
        aria-label={`table${path}`}
        cells={tableColumns}
      >
        <TableHeader />
        <TableBody />
      </PF4Table>
      <TableEmptyState
        status={status}
        error={error}
        rowsLength={tableRows.length}
      />
      <Pagination {...paginationProps('bottom')} />
    </PageLayout>
  );
};

IndexPageTemplate.propTypes = {
  path: PropTypes.string.isRequired,
  header: PropTypes.string.isRequired,
};

export default IndexPageTemplate;
