import React, { createContext } from 'react';
import { useHistory, Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { Td } from '@patternfly/react-table';
import {
  ToolbarItem,
  Dropdown,
  DropdownItem,
  KebabToggle,
  Flex,
  FlexItem,
  Button,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import { UndoIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../common/I18n';
import TableIndexPage from '../PF4/TableIndexPage/TableIndexPage';
import { ActionKebab } from './ActionKebab';
import { HOSTS_API_PATH, API_REQUEST_KEY } from '../../routes/Hosts/constants';
import { selectKebabItems } from './Selectors';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { useBulkSelect } from '../PF4/TableIndexPage/Table/TableHooks';
import SelectAllCheckbox from '../PF4/TableIndexPage/Table/SelectAllCheckbox';
import { getPageStats } from '../PF4/TableIndexPage/Table/helpers';
import { deleteHost } from '../HostDetails/ActionsBar/actions';
import { useForemanSettings } from '../../Root/Context/ForemanContext';
import { getURIsearch } from '../../common/urlHelpers';
import { bulkDeleteHosts } from './BulkActions/bulkDelete';
import { foremanUrl } from '../../common/helpers';
import Slot from '../common/Slot';
import forceSingleton from '../../common/forceSingleton';
import './index.scss';

export const ForemanHostsIndexActionsBarContext = forceSingleton(
  'ForemanHostsIndexActionsBarContext',
  () => createContext({})
);

const HostsIndex = () => {
  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ name }) => <Link to={`hosts/${name}`}>{name}</Link>,
      isSorted: true,
    },
  };

  const history = useHistory();
  const { location: { search: historySearch } = {} } = history || {};
  const urlParams = new URLSearchParams(historySearch);
  const urlParamsSearch = urlParams.get('search') || '';
  const searchFromUrl = urlParamsSearch || getURIsearch();
  const initialSearchQuery = apiSearchQuery || searchFromUrl || '';

  const defaultParams = { search: initialSearchQuery };

  const response = useAPI('get', `${HOSTS_API_PATH}?include_permissions=true`, {
    key: API_REQUEST_KEY,
    params: defaultParams,
  });

  const {
    response: {
      search: apiSearchQuery,
      results,
      subtotal,
      total,
      per_page: perPage,
      page,
    },
  } = response;

  const { pageRowCount } = getPageStats({ total, page, perPage });

  const {
    fetchBulkParams,
    updateSearchQuery,
    ...selectAllOptions
  } = useBulkSelect({
    results,
    metadata: { total, page, selectable: subtotal },
    initialSearchQuery,
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
          selectOne(isSelecting, rowData.id, rowData);
        },
        isSelected: isSelected(rowData.id),
        disable: false,
      }}
    />
  );

  RowSelectTd.propTypes = {
    rowData: PropTypes.object.isRequired,
  };
  const dispatch = useDispatch();
  const { destroyVmOnHostDelete } = useForemanSettings();
  const deleteHostHandler = ({ hostName, computeId }) =>
    dispatch(deleteHost(hostName, computeId, destroyVmOnHostDelete));
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

  const dropdownItems = [
    <DropdownItem
      ouiaId="delete=hosts-dropdown-item"
      key="delete=hosts-dropdown-item"
      onClick={handleBulkDelete}
      isDisabled={selectedCount === 0}
    >
      {__('Delete')}
    </DropdownItem>,
  ];
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const customToolbarItems = (
    <ForemanHostsIndexActionsBarContext.Provider
      value={{ ...selectAllOptions, fetchBulkParams }}
    >
      <ActionKebab items={dropdownItems.concat(registeredItems)} />
    </ForemanHostsIndexActionsBarContext.Provider>
  );

  const rowKebabItems = ({
    id,
    name: hostName,
    compute_id: computeId,
    canDelete,
  }) => [
    {
      title: __('Delete'),
      onClick: () => deleteHostHandler({ id, hostName, computeId }),
      isDisabled: !canDelete,
    },
  ];

  const [legacyUIKebabOpen, setLegacyUIKebabOpen] = React.useState(false);
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
        <h1>{__('Hosts')}</h1>
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
      apiOptions={{ key: API_REQUEST_KEY }}
      headerText={__('Hosts')}
      header={hostsIndexHeader}
      controller="hosts"
      columns={columns}
      creatable={false}
      replacementResponse={response}
      customToolbarItems={customToolbarItems}
      selectionToolbar={selectionToolbar}
      showCheckboxes
      rowSelectTd={RowSelectTd}
      rowKebabItems={rowKebabItems}
      updateSearchQuery={updateSearchQuery}
    />
  );
};

export default HostsIndex;
