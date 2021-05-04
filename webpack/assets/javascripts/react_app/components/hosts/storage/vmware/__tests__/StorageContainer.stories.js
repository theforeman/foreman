import React from 'react';
import storeDecorator from '../../../../../../../../stories/storeDecorator';
import StorageContainer from '../index';
import * as VMWareData from './StorageContainer.fixtures';
import Story from '../../../../../../../../stories/components/Story';

export default {
  title: 'Page chunks/Host VMWare Storage',
  decorators: [storeDecorator],
};

export const defaultStateForNewHost = () => {
  return (
    <Story>
      <StorageContainer data={VMWareData.state1} />
    </Story>
  );
};

defaultStateForNewHost.story = {
  name: 'default state for new host',
  decorators: [storeDecorator],
};

export const multipleControllers = () => {
  return (
    <Story>
      <StorageContainer data={VMWareData.state2} />
    </Story>
  );
};

multipleControllers.story = {
  name: 'multiple controllers',
  decorators: [storeDecorator],
};

export const onClone = () => {
  return (
    <Story>
      <StorageContainer data={VMWareData.clone} />
    </Story>
  );
};

onClone.story = {
  name: 'on clone',
  decorators: [storeDecorator],
};

export const withoutAnyControllers = () => {
  return (
    <Story>
      <StorageContainer data={VMWareData.emptyState} />
    </Story>
  );
};

withoutAnyControllers.story = {
  name: 'without any controllers',
  decorators: [storeDecorator],
};
