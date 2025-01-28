/* eslint-disable max-lines */
import React, { createContext, useState, useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { Tr, Td, ActionsColumn } from '@patternfly/react-table';
import {
  ToolbarItem,
  Divider,
  Dropdown,
  DropdownItem,
  MenuItem,
  KebabToggle,
  Flex,
  FlexItem,
  Button,
  Split,
  SplitItem,
  TextContent,
  Text,
} from '@patternfly/react-core';
import { UndoIcon } from '@patternfly/react-icons';
import { useForemanModal } from '../ForemanModal/ForemanModalHooks';
import { addModal } from '../ForemanModal/ForemanModalActions';
import { Table } from '../PF4/TableIndexPage/Table/Table';
import { translate as __ } from '../../common/I18n';
import TableIndexPage from '../PF4/TableIndexPage/TableIndexPage';
import { ActionKebab } from './ActionKebab';
import { HOSTS_API_PATH, API_REQUEST_KEY } from '../../routes/Hosts/constants';
import { selectKebabItems } from './Selectors';
import {
  useBulkSelect,
  useUrlParams,
} from '../PF4/TableIndexPage/Table/TableHooks';
import SelectAllCheckbox from '../PF4/TableIndexPage/Table/SelectAllCheckbox';
import {
  filterColumnDataByUserPreferences,
  getColumnHelpers,
  getPageStats,
} from '../PF4/TableIndexPage/Table/helpers';
import { deleteHost } from '../HostDetails/ActionsBar/actions';
import {
  useForemanSettings,
  useForemanHostsPageUrl,
} from '../../Root/Context/ForemanContext';
import { bulkDeleteHosts } from './BulkActions/bulkDelete';
import BulkBuildHostModal from './BulkActions/buildHosts';
import BulkReassignHostgroupModal from './BulkActions/reassignHostGroup';
import { foremanUrl } from '../../common/helpers';
import Slot from '../common/Slot';
import forceSingleton from '../../common/forceSingleton';
import './index.scss';
import { STATUS } from '../../constants';
import { RowSelectTd } from './RowSelectTd';
import {
  useCurrentUserTablePreferences,
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from '../PF4/TableIndexPage/Table/TableIndexHooks';
import getColumnData from './Columns/core';
import { categoriesFromFrontendColumnData } from '../ColumnSelector/helpers';
import ColumnSelector from '../ColumnSelector';
import { ForemanActionsBarContext } from '../HostDetails/ActionsBar';
import { registerGetActions, getActions } from './TableRowActions/core';

export const ForemanHostsIndexActionsBarContext = forceSingleton(
  'ForemanHostsIndexActionsBarContext',
  () => createContext({})
);

const HostsIndex = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [allColumns, setAllColumns] = useState(
    getColumnData({ tableName: 'hosts' })
  );
  const [allJsLoaded, setAllJsLoaded] = useState(false);
  const {
    searchParam: urlSearchQuery = '',
    page: urlPage,
    per_page: urlPerPage,
  } = useUrlParams();
  const defaultParams = { search: urlSearchQuery };
  if (urlPage) defaultParams.page = Number(urlPage);
  if (urlPerPage) defaultParams.per_page = Number(urlPerPage);
  const apiOptions = { key: API_REQUEST_KEY };
  const response = useTableIndexAPIResponse({
    apiUrl: HOSTS_API_PATH,
    apiOptions,
    defaultParams,
  });

  const {
    response: {
      results,
      total,
      per_page: perPage,
      page,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = response;

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions: response.setAPIOptions,
  });

  useEffect(() => {
    const handleLoadJS = () => {
      setAllColumns(getColumnData({ tableName: 'hosts' }));
      setAllJsLoaded(true);
    };
    document.addEventListener('loadJS', handleLoadJS);
    return () => {
      document.removeEventListener('loadJS', handleLoadJS);
    };
  }, [setAllColumns]);
  const {
    hasPreference,
    columns: userColumns,
    currentUserId,
  } = useCurrentUserTablePreferences({
    tableName: 'hosts',
  });
  const isLoading = status === STATUS.PENDING;
  const columns = filterColumnDataByUserPreferences(
    isLoading,
    userColumns,
    allColumns
  );
  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);

  const columnSelectData = categoriesFromFrontendColumnData({
    registeredColumns: allColumns,
    userId: currentUserId,
    tableName: 'hosts',
    userColumns,
    hasPreference,
  });

  const { pageRowCount } = getPageStats({ total, page, perPage });
  const {
    fetchBulkParams,
    updateSearchQuery,
    ...selectAllOptions
  } = useBulkSelect({
    results,
    metadata: { total, page, selectable: subtotal },
    initialSearchQuery: urlSearchQuery,
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

  const dispatch = useDispatch();
  const { destroyVmOnHostDelete } = useForemanSettings();
  const hostsIndexUrl = useForemanHostsPageUrl();
  const deleteHostHandler = ({ hostName, computeId }) =>
    dispatch(
      deleteHost(hostName, computeId, destroyVmOnHostDelete, hostsIndexUrl)
    );
  const handleBulkDelete = () => {
    const bulkParams = fetchBulkParams();
    dispatch(
      bulkDeleteHosts({
        bulkParams,
        selectedCount,
        destroyVmOnHostDelete,
      })
    );
  };

  useEffect(() => {
    dispatch(
      addModal({
        id: 'bulk-build-hosts-modal',
      })
    );
    dispatch(
      addModal({
        id: 'bulk-reassign-hg-modal',
      })
    );
  }, [dispatch]);

  const { setModalOpen: setHgModalOpen } = useForemanModal({
    id: 'bulk-reassign-hg-modal',
  });
  const { setModalOpen: setBuildModalOpen } = useForemanModal({
    id: 'bulk-build-hosts-modal',
  });

  const dropdownItems = [
    <MenuItem
      itemId="build-hosts-dropdown-item"
      key="build-hosts-dropdown-item"
      onClick={setBuildModalOpen}
      isDisabled={selectedCount === 0}
    >
      {__('Build management')}
    </MenuItem>,
    <MenuItem
      itemId="reassign-hg-dropdown-item"
      key="reassign-hg-dropdown-item"
      onClick={setHgModalOpen}
      isDisabled={selectedCount === 0}
    >
      {__('Change host group')}
    </MenuItem>,
  ];

  const dangerZoneItems = [
    <Divider
      component="li"
      id="danger-zone-separator"
      key="danger-zone-separator"
    />,
    <MenuItem
      itemId="delete=hosts-dropdown-item"
      key="delete=hosts-dropdown-item"
      onClick={handleBulkDelete}
      isDisabled={selectedCount === 0}
    >
      {__('Delete')}
    </MenuItem>,
  ];

  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const pluginToolbarItems = jsReady => (
    <ForemanHostsIndexActionsBarContext.Provider
      value={{ ...selectAllOptions, fetchBulkParams, menuOpen, setMenuOpen }}
    >
      <ActionKebab
        items={dropdownItems.concat(registeredItems).concat(dangerZoneItems)}
        menuOpen={menuOpen}
        setMenuOpen={setMenuOpen}
      />
      {jsReady && <ColumnSelector data={columnSelectData} />}
    </ForemanHostsIndexActionsBarContext.Provider>
  );

  const coreRowKebabItems = ({
    id,
    name: hostName,
    compute_id: computeId,
    can_delete: canDelete,
    can_edit: canEdit,
  }) => [
    {
      title: __('Edit'),
      onClick: () => {
        window.location.href = foremanUrl(`/hosts/${id}/edit`);
      },
      isDisabled: !canEdit,
    },
    {
      title: __('Clone'),
      onClick: () => {
        window.location.href = foremanUrl(`/hosts/${id}/clone`);
      },
      isDisabled: !canEdit,
    },
    {
      title: __('Delete'),
      onClick: () => deleteHostHandler({ id, hostName, computeId }),
      isDisabled: !canDelete,
    },
  ];

  registerGetActions({
    pluginName: 'core',
    getActionsFunc: coreRowKebabItems,
  });

  const [legacyUIKebabOpen, setLegacyUIKebabOpen] = useState(false);
  const legacyUIKebab = (
    <Dropdown
      ouiaId="legacy-ui-kebab"
      id="legacy-ui-kebab"
      position="right"
      toggle={
        <KebabToggle
          aria-label="legacy-ui-kebab-toggle"
          id="legacy-ui-kebab-toggle"
          onToggle={setLegacyUIKebabOpen}
        />
      }
      isOpen={legacyUIKebabOpen}
      isPlain
      dropdownItems={[
        <DropdownItem
          component="a"
          ouiaId="legacy-ui-link-dropdown-item"
          key="legacy-ui-link-dropdown-item"
          href="/hosts"
          icon={<UndoIcon />}
        >
          {__('Legacy UI')}
        </DropdownItem>,
      ]}
    />
  );

  const hostsIndexHeader = (
    <Flex
      alignItems={{ default: 'alignItemsCenter' }}
      justifyContent={{ default: 'justifyContentSpaceBetween' }}
    >
      <FlexItem>
        <TextContent>
          <Text ouiaId="host-header-text" component="h1">
            {__('Hosts')}
          </Text>
        </TextContent>
      </FlexItem>
      <FlexItem align={{ default: 'alignRight' }}>
        <Split hasGutter>
          <SplitItem>
            <Slot
              id="_all-hosts-schedule-a-job"
              hostSearch={selectedCount ? fetchBulkParams() : null}
              hostResponse={response}
              selectedCount={selectedCount}
            />
          </SplitItem>
          <SplitItem>
            <Button
              component="a"
              ouiaId="register-host-button"
              href={foremanUrl('/hosts/register')}
              variant="secondary"
              isDisabled={false}
            >
              {__('Register')}
            </Button>
          </SplitItem>
          <SplitItem>
            <Button
              variant="primary"
              component="a"
              ouiaId="create-host-button"
              href={foremanUrl('/hosts/new')}
            >
              {__('Create')}
            </Button>
          </SplitItem>
          <SplitItem>{legacyUIKebab}</SplitItem>
        </Split>
      </FlexItem>
    </Flex>
  );

  return (
    <TableIndexPage
      apiUrl={HOSTS_API_PATH}
      apiOptions={apiOptions}
      header={__('Hosts')}
      customHeader={hostsIndexHeader}
      controller="hosts"
      creatable={false}
      replacementResponse={response}
      customToolbarItems={pluginToolbarItems(allJsLoaded)}
      selectionToolbar={selectionToolbar}
      updateSearchQuery={updateSearchQuery}
    >
      <Table
        ouiaId="hosts-index-table"
        params={params}
        setParams={setParamsAndAPI}
        getActions={getActions}
        itemCount={subtotal}
        results={results}
        url={HOSTS_API_PATH}
        isDeleteable
        showCheckboxes
        refreshData={() =>
          setAPIOptions({
            ...apiOptions,
            params: { search: urlSearchQuery },
          })
        }
        columns={columns}
        errorMessage={
          status === STATUS.ERROR && errorMessage ? errorMessage : null
        }
        isPending={status === STATUS.PENDING}
      >
        {results?.map((result, rowIndex) => {
          const rowActions = getActions(result);
          return (
            <Tr key={rowIndex} ouiaId={`table-row-${rowIndex}`} isHoverable>
              {<RowSelectTd rowData={result} {...{ selectOne, isSelected }} />}
              {columnNamesKeys.map(k => (
                <Td key={k} dataLabel={keysToColumnNames[k]}>
                  {columns[k].wrapper ? columns[k].wrapper(result) : result[k]}
                </Td>
              ))}
              <Td isActionCell>
                {rowActions.length ? (
                  <ActionsColumn items={rowActions} />
                ) : null}
              </Td>
            </Tr>
          );
        })}
      </Table>
      <ForemanActionsBarContext.Provider
        value={{ selectedCount, fetchBulkParams }}
      >
        <BulkBuildHostModal key="bulk-build-hosts-modal" />
        <BulkReassignHostgroupModal key="bulk-reassign-hg-modal" />
        <Slot id="_all-hosts-modals" multi />
      </ForemanActionsBarContext.Provider>
    </TableIndexPage>
  );
};

export default HostsIndex;
