import React from 'react';
import { storiesOf } from '@storybook/react';
import PowerStatusInner from './index';

storiesOf('Components/Power Status', module)
  .add('Loading', () => <PowerStatusInner />)
  .add('ON', () => <PowerStatusInner state="on" title="on" statusText="On" />)
  .add('OFF', () => <PowerStatusInner state="off" title="off" statusText="Off" />)
  .add('N/A', () => <PowerStatusInner state="na" statusText="No power support" title="N/A" />)
  .add('Error', () => (
    <PowerStatusInner
      state="na"
      statusText="Exception error some where"
      error="someError"
      title="N/A"
    />
  ));
