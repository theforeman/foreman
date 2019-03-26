import React from 'react';
import { storiesOf } from '@storybook/react';
import Store from '../../../../../redux';
import StorageContainer from '../index';
import * as VMWareData from './StorageContainer.fixtures';
import { mockRequest } from '../../../../../mockRequests';
import Story from '../../../../../../../../stories/components/Story';

const initializeMocks = () => {
  mockRequest({
    url: '/api/v2/compute_resources/1/available_storage_domains',
    response: VMWareData.storageDomainResponse,
  });

  mockRequest({
    url: '/api/v2/compute_resources/1/available_storage_pods',
    response: VMWareData.storagePodResponse,
  });
};

storiesOf('Page chunks/Host VMWare Storage', module)
  .add('default state for new host', () => {
    initializeMocks();
    return (
      <Story>
        <StorageContainer store={Store} data={VMWareData.state1} />
      </Story>
    );
  })
  .add('multiple controllers', () => {
    initializeMocks();
    return (
      <Story>
        <StorageContainer store={Store} data={VMWareData.state2} />
      </Story>
    );
  })
  .add('on clone', () => {
    initializeMocks();
    return (
      <Story>
        <StorageContainer store={Store} data={VMWareData.clone} />
      </Story>
    );
  })
  .add('without any controllers', () => {
    initializeMocks();
    return (
      <Story>
        <StorageContainer store={Store} data={VMWareData.emptyState} />
      </Story>
    );
  });
