import React, { createContext } from 'react';
import PropTypes from 'prop-types';
import { useSelector, shallowEqual } from 'react-redux';
import { Td } from '@patternfly/react-table';
import { ToolbarItem } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import TableIndexPage from '../PF4/TableIndexPage/TableIndexPage';
import { ActionKebab } from './ActionKebab';
import { HOSTS_API_PATH, API_REQUEST_KEY } from '../../routes/Hosts/constants';
import { selectKebabItems } from './Selectors';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { useBulkSelect } from '../PF4/TableIndexPage/Table/TableHooks';
import SelectAllCheckbox from '../PF4/TableIndexPage/Table/SelectAllCheckbox';
import { getPageStats } from '../PF4/TableIndexPage/Table/helpers';

export const ForemanHostsIndexActionsBarContext = createContext({});

const HostsIndex = () => {
  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ id, name }) => <a href={`hosts/${id}`}>{name}</a>,
      isSorted: true,
    },
  };
  const defaultParams = { search: '' }; // search ||

  const response = useAPI('get', `${HOSTS_API_PATH}?include_permissions=true`, {
    key: API_REQUEST_KEY,
    params: defaultParams,
  });

  const {
    response: {
      search: apiSearchQuery,
      results,
      total,
      per_page: perPage,
      page,
    },
  } = response;

  const { pageRowCount } = getPageStats({ total, page, perPage });

  const { fetchBulkParams, ...selectAllOptions } = useBulkSelect({
    results,
    metadata: { total, page },
    initialSearchQuery: apiSearchQuery || '',
  });

  const {
    selectAll,
    selectPage,
    selectNone,
    selectedCount,
    selectOne,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    isSelected,
  } = selectAllOptions;

  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectAll,
          selectPage,
          selectNone,
          selectedCount,
          pageRowCount,
        }}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const RowSelectTd = ({ rowData }) => (
    <Td
      select={{
        rowIndex: rowData.id,
        onSelect: (_event, isSelecting) => {
          selectOne(isSelecting, rowData.id);
        },
        isSelected: isSelected(rowData.id),
        disable: false,
      }}
    />
  );

  RowSelectTd.propTypes = {
    rowData: PropTypes.object.isRequired,
  };

  const actionNode = [];
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const customToolbarItems = (
    <ForemanHostsIndexActionsBarContext.Provider
      value={{ ...selectAllOptions, fetchBulkParams }}
    >
      <ActionKebab items={actionNode.concat(registeredItems)} />
    </ForemanHostsIndexActionsBarContext.Provider>
  );

  return (
    <TableIndexPage
      apiUrl={HOSTS_API_PATH}
      apiOptions={{ key: API_REQUEST_KEY }}
      header={__('Hosts')}
      controller="hosts"
      isDeleteable
      columns={columns}
      creatable={false}
      replacementResponse={response}
      customToolbarItems={customToolbarItems}
      selectionToolbar={selectionToolbar}
      showCheckboxes
      rowSelectTd={RowSelectTd}
    />
  );
};

export default HostsIndex;
