import React from 'react';
import { storiesOf } from '@storybook/react';
import HostChart from './HostChart';
import { STATUS } from '../../../constants';

const getConfig = (hostname, status) => ({
  charts: {
    [hostname]: {
      results: [],
      status,
    },
  },
  data: {
    name: hostname,
    url: `host/${hostname}/resources`,
  },
});

storiesOf('HostChart', module)
  .add('Loading', () => (
    <HostChart {...getConfig('host31', STATUS.PENDING)} />
  ))
  .add('Without Data', () => (
    <HostChart {...getConfig('host22', STATUS.RESOLVED)}/>
  ))
  .add('Line Chart', () => (
    <HostChart
      charts={{
        host1: {
          results: [
            {
              label: 'Skipped',
              data: [
                [1527137948000, 1],
                [1527171330000, 2],
                [1527237948000, 3],
              ],
              color: '#b7b549',
            },
            {
              label: 'Failed',
              data: [
                [1527137948000, 0],
                [1527171330000, 0],
                [1527237948000, 0],
              ],
              color: '#91071b',
            },
            {
              label: 'Applied',
              data: [
                [1527137948000, 10],
                [1527171330000, 10],
                [1527237948000, 10],
              ],
              color: '#42a4f4',
            },
          ],
          status: STATUS.RESOLVED,
        },
      }}
      data={{ name: 'host1', url: 'host/host1/runtime', type: 'area' }}
    />
  ))
  .add('Area Chart', () => (
    <HostChart
      charts={{
        host1: {
          results: [
            {
              label: 'Runtime',
              data: [
                [1527137948000, 20],
                [1527171330000, 20],
              ],
              color: '#357172',
            },
            {
              label: 'Config Retrieval',
              data: [
                [1527137948000, 5],
                [1527171330000, 5],
              ],
              color: '#7891ba',
            },
          ],
          status: STATUS.RESOLVED,
        },
      }}
      data={{ name: 'host1', url: 'host/host1/runtime', type: 'area' }}
    />
  ));
