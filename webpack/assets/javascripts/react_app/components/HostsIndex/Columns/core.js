/* eslint-disable camelcase */
import React from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from '../../../common/I18n';

const coreHostsIndexColumns = [
  {
    columnName: 'name',
    title: __('Name'),
    wrapper: ({ name }) => <Link to={`hosts/${name}`}>{name}</Link>,
    isSorted: true,
  },
  {
    columnName: 'hostgroup',
    title: __('Host group'),
    wrapper: hostDetails => hostDetails?.hostgroup_name,
    isSorted: true,
  },
  {
    columnName: 'os_title',
    title: __('OS'),
    wrapper: hostDetails => hostDetails?.operatingsystem_name,
    isSorted: true,
  },
  {
    columnName: 'owner',
    title: __('Owner'),
    wrapper: hostDetails => hostDetails?.owner_name,
    isSorted: true,
  },
  {
    // eslint-disable-next-line spellcheck/spell-checker
    columnName: 'last_checkin',
    title: __('Last seen'),
    wrapper: hostDetails => hostDetails?.last_checkin,
  },
];

coreHostsIndexColumns.forEach(column => {
  column.tableName = 'hosts';
});

export const CoreColumns = ({ tableName = 'hosts' }) => {
  const result = {};
  coreHostsIndexColumns.forEach(column => {
    if (column.tableName === tableName) {
      result[column.columnName] = column;
    }
  });
  return result;
};

export default CoreColumns;
