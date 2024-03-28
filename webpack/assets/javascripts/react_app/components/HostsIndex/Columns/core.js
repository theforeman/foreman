/* eslint-disable camelcase */
import React from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from '../../../common/I18n';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import forceSingleton from '../../../common/forceSingleton';

const coreHostsIndexColumns = [
  {
    columnName: 'name',
    title: __('Name'),
    wrapper: ({ name }) => <Link to={`hosts/${name}`}>{name}</Link>,
    isSorted: true,
    weight: 0,
  },
  {
    columnName: 'hostgroup',
    title: __('Host group'),
    wrapper: hostDetails => hostDetails?.hostgroup_name,
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
    wrapper: hostDetails => hostDetails?.owner_name,
    isSorted: true,
    weight: 300,
  },
];

coreHostsIndexColumns.forEach(column => {
  column.tableName = 'hosts';
});

const coreColumnRegistry = forceSingleton('coreColumnRegistry', () => ({}));

export const registerColumns = columns => {
  columns.forEach(column => {
    coreColumnRegistry[column.columnName] = column;
  });
};

registerColumns(coreHostsIndexColumns);

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
