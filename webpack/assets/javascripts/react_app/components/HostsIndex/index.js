/* eslint-disable max-lines */
import React, { createContext, useState, useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { Tr, Td, ActionsColumn } from '@patternfly/react-table';
import {
  ToolbarItem,
  Divider,
  Flex,
  FlexItem,
  Button,
  Menu,
  MenuItem,
  MenuContent,
  MenuList,
  Split,
  SplitItem,
  TextContent,
  Text,
  Icon,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core/deprecated';
import { UndoIcon } from '@patternfly/react-icons';
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
  useForemanContext,
} from '../../Root/Context/ForemanContext';
import { bulkDeleteHosts } from './BulkActions/bulkDelete';
import {
  BulkAssignOrganizationModalScene as BulkAssignOrganizationModal,
  BulkAssignLocationModalScene as BulkAssignLocationModal,
} from './BulkActions/assignTaxonomy';
import BulkBuildHostModal from './BulkActions/buildHosts';
import BulkReassignHostgroupModal from './BulkActions/reassignHostGroup';
import BulkChangeOwnerModal from './BulkActions/changeOwner';
import BulkDisassociateModal from './BulkActions/disassociate';
import BulkPowerStateModal from './BulkActions/powerState/index';
import BulkManageNotificationsModal from './BulkActions/manageNotifications';
import { foremanUrl } from '../../common/helpers';
import Slot from '../common/Slot';
import forceSingleton from '../../common/forceSingleton';
import { HostsPowerRefreshContext } from './HostsPowerRefreshContext';
import './index.scss';
import { STATUS } from '../../constants';
import { RowSelectTd } from '../PF4/TableIndexPage/RowSelectTd';
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
  const [powerRefreshId, setPowerRefreshId] = useState(0);
  const bumpPowerRefresh = () => setPowerRefreshId(prev => prev + 1);
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
    syncWithOptions: true,
  });
  const contextData = useForemanContext();

  const {
    response: {
      search: apiSearchQuery,
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

  /* eslint-disable consistent-return */
  useEffect(() => {
    const handleLoadJS = () => {
      setAllColumns(getColumnData({ tableName: 'hosts' }));
      setAllJsLoaded(true);
    };
    if (window.allJsLoaded) {
      handleLoadJS();
    } else {
      document.addEventListener('loadJS', handleLoadJS);
      return () => {
        document.removeEventListener('loadJS', handleLoadJS);
      };
    }
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
    allColumns,
    contextData
  );
  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);
  const columnSelectData = categoriesFromFrontendColumnData({
    registeredColumns: allColumns,
    userId: currentUserId,
    tableName: 'hosts',
    userColumns,
    hasPreference,
    contextData,
  });

  const { pageRowCount } = getPageStats({ total, page, perPage });
  const {
    fetchBulkParams,
    searchQuery,
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
    selectedResults,
  } = selectAllOptions;
  const selectAllHostsMode = areAllRowsSelected() && searchQuery === '';

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
  const refreshTableData = () =>
    setAPIOptions({
      ...apiOptions,
      params: { search: urlSearchQuery },
    });
  const deleteHostHandler = ({ hostName, computeId }) =>
    dispatch(
      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        onDeleteSuccess: refreshTableData,
      })
    );
  const handleBulkDelete = () => {
    const bulkParams = fetchBulkParams();
    dispatch(
      bulkDeleteHosts({
        bulkParams,
        selectedCount,
        destroyVmOnHostDelete,
        onDeleteSuccess: () => {
          selectNone();
          refreshTableData();
        },
      })
    );
  };

  const [organizationModalOpen, setOrganizationModalOpen] = useState(false);
  const [locationModalOpen, setLocationModalOpen] = useState(false);
  const [hgModalOpen, setHgModalOpen] = useState(false);
  const [buildModalOpen, setBuildModalOpen] = useState(false);
  const [changeOwnerModalOpen, setChangeOwnerModalOpen] = useState(false);
  const [disassociateModalOpen, setDisassociateModalOpen] = useState(false);
  const [powerStateModalOpen, setPowerStateModalOpen] = useState(false);
  const [notificationsModalOpen, setNotificationsModalOpen] = useState(false);

  const dropdownItems = [
    <MenuItem
      itemId="build-hosts-dropdown-item"
      key="build-hosts-dropdown-item"
      onClick={() => setBuildModalOpen(true)}
      isDisabled={selectedCount === 0}
    >
      {__('Build management')}
    </MenuItem>,
    <MenuItem
      itemId="disassociate-dropdown-item"
      key="disassociate-dropdown-item"
      onClick={() => setDisassociateModalOpen(true)}
      isDisabled={selectedCount === 0}
    >
      {__('Disassociate hosts')}
    </MenuItem>,
    <MenuItem
      itemId="power-state-dropdown-item"
      key="power-state-dropdown-item"
      onClick={() => setPowerStateModalOpen(true)}
      isDisabled={selectedCount === 0}
    >
      {__('Change power state')}
    </MenuItem>,
    <MenuItem
      itemId="manage-notifications-dropdown-item"
      key="manage-notifications-dropdown-item"
      onClick={() => setNotificationsModalOpen(true)}
      isDisabled={selectedCount === 0}
    >
      {__('Manage notifications')}
    </MenuItem>,
    <MenuItem
      itemId="host-association-dropdown-item"
      key="host-association-dropdown-item"
      isDisabled={selectedCount === 0}
      flyoutMenu={
        <Menu
          ouiaId="host-association-dropdown-menu"
          onSelect={() => setMenuOpen(false)}
        >
          <MenuContent>
            <MenuList>
              <MenuItem
                itemId="reassign-hg-dropdown-item"
                key="reassign-hg-dropdown-item"
                onClick={() => setHgModalOpen(true)}
                isDisabled={selectedCount === 0}
              >
                {__('Host group')}
              </MenuItem>
              <Slot
                id="_host-associations"
                fetchBulkParams={fetchBulkParams}
                selectedCount={selectedCount}
                multi
              />
              <MenuItem
                itemId="change-owner-dropdown-item"
                key="change-owner-dropdown-item"
                onClick={() => setChangeOwnerModalOpen(true)}
                isDisabled={selectedCount === 0}
              >
                {__('Owner')}
              </MenuItem>
              <MenuItem
                itemId="assign-organization-dropdown-item"
                key="assign-organization-dropdown-item"
                onClick={() => setOrganizationModalOpen(true)}
                isDisabled={selectedCount === 0}
              >
                {__('Organization')}
              </MenuItem>
              <MenuItem
                itemId="assign-location-dropdown-item"
                key="assign-location-dropdown-item"
                onClick={() => setLocationModalOpen(true)}
                isDisabled={selectedCount === 0}
              >
                {__('Location')}
              </MenuItem>
            </MenuList>
          </MenuContent>
        </Menu>
      }
    >
      {__('Change associations')}
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
          onToggle={(_event, val) => setLegacyUIKebabOpen(val)}
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
          icon={
            <Icon>
              <UndoIcon />
            </Icon>
          }
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
              ouiaId="export-hosts-button"
              href={foremanUrl(
                `${hostsIndexUrl}.csv${
                  searchQuery
                    ? `?search=${encodeURIComponent(searchQuery)}`
                    : ''
                }`
              )}
              variant="secondary"
              isDisabled={false}
            >
              {__('Export')}
            </Button>
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

  // Exclude stale perPage from params to avoid duplicating it with per_page
  const { perPage: _, ...paramsWithoutPerPage } = params;

  return (
    <HostsPowerRefreshContext.Provider
      value={{ refreshId: powerRefreshId, bumpRefresh: bumpPowerRefresh }}
    >
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
          params={{
            ...paramsWithoutPerPage,
            page,
            per_page: perPage,
            search: apiSearchQuery,
          }}
          setParams={setParamsAndAPI}
          getActions={getActions}
          itemCount={subtotal}
          results={results}
          url={HOSTS_API_PATH}
          isDeleteable
          showCheckboxes
          refreshData={refreshTableData}
          columns={columns}
          errorMessage={
            status === STATUS.ERROR && errorMessage ? errorMessage : null
          }
          isPending={status === STATUS.PENDING}
        >
          {results?.map(result => {
            const rowActions = getActions(result);
            return (
              <Tr key={result.id} ouiaId={`table-row-${result.id}`} isClickable>
                {
                  <RowSelectTd
                    rowData={result}
                    {...{ selectOne, isSelected }}
                  />
                }
                {columnNamesKeys.map(k => (
                  <Td
                    key={k}
                    dataLabel={keysToColumnNames[k]}
                    textCenter={columns[k]?.textCenter}
                  >
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
          })}
        </Table>
        <ForemanActionsBarContext.Provider
          value={{
            selectAllHostsMode,
            selectedCount,
            selectedResults,
            fetchBulkParams,
          }}
        >
          <BulkAssignOrganizationModal
            key="bulk-assign-organization-modal"
            isOpen={organizationModalOpen}
            closeModal={() => setOrganizationModalOpen(false)}
          />
          <BulkAssignLocationModal
            key="bulk-assign-location-modal"
            isOpen={locationModalOpen}
            closeModal={() => setLocationModalOpen(false)}
          />
          <BulkBuildHostModal
            key="bulk-build-hosts-modal"
            isOpen={buildModalOpen}
            closeModal={() => setBuildModalOpen(false)}
          />
          <BulkReassignHostgroupModal
            key="bulk-reassign-hg-modal"
            isOpen={hgModalOpen}
            closeModal={() => setHgModalOpen(false)}
          />
          <BulkChangeOwnerModal
            key="bulk-change-owner-modal"
            isOpen={changeOwnerModalOpen}
            closeModal={() => setChangeOwnerModalOpen(false)}
          />
          <BulkPowerStateModal
            key="bulk-power-state-modal"
            isOpen={powerStateModalOpen}
            closeModal={() => setPowerStateModalOpen(false)}
          />
          <BulkDisassociateModal
            key="bulk-disassociate-modal"
            isOpen={disassociateModalOpen}
            closeModal={() => setDisassociateModalOpen(false)}
          />
          <BulkManageNotificationsModal
            key="bulk-manage-notifications-modal"
            isOpen={notificationsModalOpen}
            closeModal={() => setNotificationsModalOpen(false)}
            // Re-fetch hosts with the current search so the table stays in sync
            onSuccess={() =>
              setAPIOptions({
                ...apiOptions,
                params: { search: urlSearchQuery },
              })
            }
          />
          <Slot id="_all-hosts-modals" multi />
        </ForemanActionsBarContext.Provider>
      </TableIndexPage>
    </HostsPowerRefreshContext.Provider>
  );
};

export default HostsIndex;
