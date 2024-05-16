/* eslint-disable camelcase */
import React from 'react';
import { Link } from 'react-router-dom';
import { TableText } from '@patternfly/react-table';
import { UserIcon, UsersIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import forceSingleton from '../../../common/forceSingleton';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import HostPowerStatus from './components/HostPowerStatus';

const coreHostsIndexColumns = [
  {
    columnName: 'power_status',
    title: __('Power'),
    wrapper: ({ name }) => <HostPowerStatus hostName={name} />,
    isSorted: false,
    weight: 0,
  },
  {
    columnName: 'name',
    title: __('Name'),
    wrapper: ({ name, display_name: displayName }) => (
      <Link to={`hosts/${name}`}>{displayName}</Link>
    ),
    isSorted: true,
    weight: 50,
    isRequired: true,
  },
  {
    columnName: 'hostgroup',
    title: __('Host group'),
    wrapper: hostDetails => (
      <a href={`/hostgroups/${hostDetails?.hostgroup_id}/edit`}>
        {hostDetails?.hostgroup_name}
      </a>
    ),
    isSorted: true,
    weight: 100,
  },
  {
    columnName: 'os_title',
    title: __('OS'),
    wrapper: hostDetails => hostDetails?.operatingsystem_name,
    isSorted: true,
    weight: 200,
  },
  {
    columnName: 'owner',
    title: __('Owner'),
    wrapper: hostDetails => {
      if (!hostDetails?.owner_name) return null;
      const OwnerIcon =
        hostDetails?.owner_type !== 'User' ? UsersIcon : UserIcon;
      return (
        <TableText>
          <OwnerIcon color="#2B9AF3" style={{ marginRight: '5px' }} />
          {hostDetails?.owner_name}
        </TableText>
      );
    },
    isSorted: true,
    weight: 300,
  },
  {
    columnName: 'boot_time',
    title: __('Boot time'),
    wrapper: hostDetails => {
      const bootTime = hostDetails?.reported_data?.boot_time;
      return <RelativeDateTime defaultValue={__('Unknown')} date={bootTime} />;
    },
    isSorted: true,
    weight: 400,
  },
  {
    columnName: 'last_report',
    title: __('Last report'),
    wrapper: hostDetails => {
      const lastReport = hostDetails?.last_report;
      return (
        <RelativeDateTime defaultValue={__('Unknown')} date={lastReport} />
      );
    },
    isSorted: true,
    weight: 500,
  },
  {
    columnName: 'comment',
    title: __('Comment'),
    wrapper: hostDetails => (
      <TableText wrapModifier="truncate">
        {hostDetails?.comment ?? ''}
      </TableText>
    ),
    isSorted: true,
    weight: 600,
  },
];

coreHostsIndexColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'General';
  column.categoryKey = 'general';
});

const networkColumns = [
  {
    columnName: 'ip',
    title: 'IPv4',
    wrapper: hostDetails => hostDetails?.ip,
    isSorted: true,
    weight: 700,
  },
  {
    columnName: 'ip6',
    title: 'IPv6',
    wrapper: hostDetails => hostDetails?.ip6,
    isSorted: true,
    weight: 800,
  },
  {
    columnName: 'mac',
    title: 'MAC',
    wrapper: hostDetails => hostDetails?.mac,
    isSorted: true,
    weight: 900,
  },
];

networkColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'Network';
  column.categoryKey = 'network';
});

const reportedDataColumns = [
  {
    columnName: 'model',
    title: __('Model'),
    wrapper: hostDetails =>
      hostDetails?.compute_resource_name || hostDetails?.model_name,
    isSorted: true,
    weight: 1000,
  },
  {
    columnName: 'sockets',
    title: __('Sockets'),
    wrapper: hostDetails => hostDetails?.reported_data?.sockets,
    isSorted: false,
    weight: 1100,
  },
  {
    columnName: 'cores',
    title: __('Cores'),
    wrapper: hostDetails => hostDetails?.reported_data?.cores,
    isSorted: false,
    weight: 1200,
  },
  {
    columnName: 'ram',
    title: __('RAM'),
    wrapper: hostDetails => hostDetails?.reported_data?.ram,
    isSorted: false,
    weight: 1300,
  },
  // { // TODO: make virtual work
  //   columnName: 'virtual',
  //   title: __('Virtual'),
  //   wrapper: hostDetails => hostDetails?.reported_data?.virtual,
  //   isSorted: false,
  //   weight: 1400,
  // },
  {
    columnName: 'disks_total',
    title: __('Total disk space'),
    wrapper: hostDetails => hostDetails?.reported_data?.disks_total,
    isSorted: false,
    weight: 1500,
  },
  {
    columnName: 'kernel_version',
    title: __('Kernel version'),
    wrapper: hostDetails => hostDetails?.reported_data?.kernel_version,
    isSorted: false,
    weight: 1600,
  },
  {
    columnName: 'bios_vendor',
    title: __('BIOS vendor'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_vendor,
    isSorted: false,
    weight: 1700,
  },
  {
    columnName: 'bios_release_date',
    title: __('BIOS release date'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_release_date,
    isSorted: false,
    weight: 1800,
  },
  {
    columnName: 'bios_version',
    title: __('BIOS version'),
    wrapper: hostDetails => hostDetails?.reported_data?.bios_version,
    isSorted: false,
    weight: 1900,
  },
];

reportedDataColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'Reported data';
  column.categoryKey = 'reported_data';
});

const coreColumnRegistry = forceSingleton('coreColumnRegistry', () => ({}));

export const registerColumns = columns => {
  columns.forEach(column => {
    coreColumnRegistry[column.columnName] = column;
  });
};

registerColumns(coreHostsIndexColumns);
registerColumns(networkColumns);
registerColumns(reportedDataColumns);

export const RegisteredColumns = ({ tableName = 'hosts' }) => {
  const result = {};
  Object.keys(coreColumnRegistry).forEach(column => {
    if (coreColumnRegistry[column]?.tableName === tableName) {
      result[column] = coreColumnRegistry[column];
    }
  });
  return result;
};

export default RegisteredColumns;
