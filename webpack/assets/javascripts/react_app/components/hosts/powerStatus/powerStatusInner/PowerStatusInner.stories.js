import React from 'react';
import { storiesOf } from '@storybook/react';
import PowerStatusInner from './index';
import Story from '../../../../../../../stories/components/Story';

storiesOf('Components/Power Status', module)
  .add('Loading', () => (
    <Story>
      <PowerStatusInner />
    </Story>
  ))
  .add('ON', () => (
    <Story>
      <PowerStatusInner state="on" title="on" statusText="On" />
    </Story>
  ))
  .add('OFF', () => (
    <Story>
      <PowerStatusInner state="off" title="off" statusText="Off" />
    </Story>
  ))
  .add('N/A', () => (
    <Story>
      <PowerStatusInner state="na" statusText="No power support" title="N/A" />
    </Story>
  ))
  .add('Error', () => (
    <Story>
      <PowerStatusInner
        state="na"
        statusText="Exception error some where"
        error="someError"
        title="N/A"
      />
    </Story>
  ));
