import React from 'react';
import { storiesOf } from '@storybook/react';
import Store from '../../../../redux';
import StorageContainer from './index';
import * as VMWareData from './StorageContainer.fixtures';

storiesOf('Host VMWare Storage', module)
  .add('default state for new host', () => (
    <StorageContainer store={Store} data={VMWareData.state1} />
  ))
  .add('multiple controllers', () => (
    <StorageContainer store={Store} data={VMWareData.state2} />
  ))
  .add('on clone', () => (
    <StorageContainer store={Store} data={VMWareData.clone} />
  ))
  .add('without any controllers', () => (
    <StorageContainer store={Store} data={VMWareData.emptyState} />
  ));
