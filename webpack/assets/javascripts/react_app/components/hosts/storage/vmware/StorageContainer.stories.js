import React from 'react';
import { storiesOf } from '@storybook/react';
import Store from '../../../../redux';
import StorageContainer from './index';
import * as VMWareData from './StorageContainer.fixtures';
import { mockRequest } from '../../../../mockRequests';

const initializeMocks = () => {
  mockRequest({
    url: '/api/v2/compute_resources/1/available_storage_domains',
    response: {
      results: [{
        name: 'MyDatastore', id: 'datastore-608634', capacity: 2199023255552, freespace: 659551158272, uncommitted: 4076735943455,
      }],
    },
  });

  mockRequest({
    url: '/api/v2/compute_resources/1/available_storage_pods',
    response: {
      results: [{
        name: 'MyStoragePod', id: 'group-p859969', capacity: 5497021267968, freespace: 4829829136384,
      }],
    },
  });
};


storiesOf('Components/Host VMWare Storage', module)
  .add('default state for new host', () => {
    initializeMocks();
    return <StorageContainer store={Store} data={VMWareData.state1} />;
  })
  .add('multiple controllers', () => {
    initializeMocks();
    return <StorageContainer store={Store} data={VMWareData.state2} />;
  })
  .add('on clone', () => {
    initializeMocks();
    return <StorageContainer store={Store} data={VMWareData.clone} />;
  })
  .add('without any controllers', () => {
    initializeMocks();
    return <StorageContainer store={Store} data={VMWareData.emptyState} />;
  });
