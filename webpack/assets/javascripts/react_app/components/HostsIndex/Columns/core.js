/* eslint-disable camelcase */
import React from 'react';
import { Link } from 'react-router-dom';
import { TableText } from '@patternfly/react-table';
import {
  Popover,
  TextContent,
  TextList,
  TextListItem,
} from '@patternfly/react-core';
import { UserIcon, UsersIcon } from '@patternfly/react-icons';
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
import { translate as __ } from '../../../common/I18n';
import forceSingleton from '../../../common/forceSingleton';
import { foremanUrl } from '../../../common/helpers';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import HostPowerStatus from './components/HostPowerStatus';
import GlobalStatusIcon from '../../HostStatuses/Status/GlobalStatusIcon';

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
    wrapper: ({
      name,
      display_name: displayName,
      global_status: globalStatus,
      global_status_fulltext: statuses,
    }) => (
      <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
        <Popover
          id="host-index-global-status-tooltip"
          bodyContent={
            <TextContent>
              <TextList isPlain>
                {statuses.map((status, index) => (
                  <TextListItem key={`status-list-${index}`}>
                    {status}
                  </TextListItem>
                ))}
              </TextList>
            </TextContent>
          }
        >
          <GlobalStatusIcon status={globalStatus} />
        </Popover>
        <Link to={`hosts/${name}`}>{displayName}</Link>
      </span>
    ),
    isSorted: true,
    weight: 50,
    isRequired: true,
  },
  {
    columnName: 'organization',
    title: __('Organization'),
    wrapper: hostDetails => hostDetails?.organization_name,
    isSorted: false,
    weight: 75,
  },
  {
    columnName: 'location',
    title: __('Location'),
    wrapper: hostDetails => hostDetails?.location_name,
    isSorted: false,
    weight: 80,
  },
  {
    columnName: 'hostgroup',
    title: __('Host group'),
    wrapper: hostDetails => {
      const fullTitle = hostDetails?.hostgroup_title;
      const name = hostDetails?.hostgroup_name;
      return (
        <span>
          {fullTitle?.substring(0, fullTitle?.lastIndexOf(name))}
          <a href={`/hostgroups/${hostDetails?.hostgroup_id}/edit`}>{name}</a>
        </span>
      );
    },
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
      return lastReport ? (
        <Link to={foremanUrl(`/hosts/${hostDetails.name}/config_reports/last`)}>
          <RelativeDateTime date={lastReport} />
        </Link>
      ) : (
        __('No report')
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
    wrapper: hostDetails => {
      if (!hostDetails?.reported_data?.ram) return null;
      return NumberToHumanSize(hostDetails.reported_data.ram * 1024 * 1024, {
        strip_insignificant_zeros: true,
      });
    },
    isSorted: false,
    weight: 1300,
  },
  {
    columnName: 'virtual',
    title: __('Virtual'),
    wrapper: hostDetails => {
      const value = hostDetails?.reported_data?.virtual;
      if (value === undefined || value === null) {
        return '';
      }
      if (value) {
        return __('Virtual');
      }
      return __('Physical');
    },
    isSorted: false,
    weight: 1400,
  },
  {
    columnName: 'disks_total',
    title: __('Total disk space'),
    wrapper: hostDetails => {
      if (!hostDetails?.reported_data?.disks_total) return null;
      return NumberToHumanSize(hostDetails.reported_data.disks_total, {
        strip_insignificant_zeros: true,
      });
    },
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
