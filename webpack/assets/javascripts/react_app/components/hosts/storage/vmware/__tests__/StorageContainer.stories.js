import React from 'react';
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

export default {
  title: 'Page chunks|Host VMWare Storage',
};

export const defaultStateForNewHost = () => {
  initializeMocks();
  return (
    <Story>
      <StorageContainer store={Store} data={VMWareData.state1} />
    </Story>
  );
};

defaultStateForNewHost.story = {
  name: 'default state for new host',
};

export const multipleControllers = () => {
  initializeMocks();
  return (
    <Story>
      <StorageContainer store={Store} data={VMWareData.state2} />
    </Story>
  );
};

multipleControllers.story = {
  name: 'multiple controllers',
};

export const onClone = () => {
  initializeMocks();
  return (
    <Story>
      <StorageContainer store={Store} data={VMWareData.clone} />
    </Story>
  );
};

onClone.story = {
  name: 'on clone',
};

export const withoutAnyControllers = () => {
  initializeMocks();
  return (
    <Story>
      <StorageContainer store={Store} data={VMWareData.emptyState} />
    </Story>
  );
};

withoutAnyControllers.story = {
  name: 'without any controllers',
};
