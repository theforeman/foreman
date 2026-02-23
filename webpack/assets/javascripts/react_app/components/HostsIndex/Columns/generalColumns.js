/* eslint-disable camelcase */
import React from 'react';
import { Link } from 'react-router-dom';
import { TableText } from '@patternfly/react-table';
import {
  Button,
  Icon,
  Popover,
  TextContent,
  TextList,
  TextListItem,
} from '@patternfly/react-core';
import { UserIcon, UsersIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import { foremanUrl } from '../../../common/helpers';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import HostPowerStatus from './components/HostPowerStatus';
import GlobalStatusIcon from '../../HostStatuses/Status/GlobalStatusIcon';
import './core.scss';

const generalColumns = [
  {
    columnName: 'power_status',
    title: __('Power'),
    wrapper: ({ name }) => <HostPowerStatus hostName={name} />,
    isSorted: false,
    weight: 0,
    textCenter: true,
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
          <Button
            variant="plain"
            ouiaId="plain-button-popover"
            style={{ padding: 0 }}
          >
            <GlobalStatusIcon status={globalStatus} />
          </Button>
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
    wrapper: hostDetails => {
      const osIcon = hostDetails?.operatingsystem_icon;
      const osName = hostDetails?.operatingsystem_name;
      return (
        <span className="os-title-wrapper">
          {osIcon && <img src={osIcon} alt={`${osName} icon`} />}
          <span>{osName}</span>
        </span>
      );
    },
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
          <Icon style={{ color: '#2B9AF3', marginRight: '5px' }}>
            <OwnerIcon />
          </Icon>
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

generalColumns.forEach(column => {
  column.tableName = 'hosts';
  column.categoryName = 'General';
  column.categoryKey = 'general';
});

export default generalColumns;
