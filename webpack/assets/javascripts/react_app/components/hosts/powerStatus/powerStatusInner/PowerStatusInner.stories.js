import React from 'react';
import PowerStatusInner from './index';
import Story from '../../../../../../../stories/components/Story';

export default {
  title: 'Components|Power Status',
};

export const loading = () => (
  <Story>
    <PowerStatusInner />
  </Story>
);

export const on = () => (
  <Story>
    <PowerStatusInner state="on" title="on" statusText="On" />
  </Story>
);

on.story = {
  name: 'ON',
};

export const off = () => (
  <Story>
    <PowerStatusInner state="off" title="off" statusText="Off" />
  </Story>
);

off.story = {
  name: 'OFF',
};

export const nA = () => (
  <Story>
    <PowerStatusInner state="na" statusText="No power support" title="N/A" />
  </Story>
);

nA.story = {
  name: 'N/A',
};

export const errorStory = () => (
  <Story>
    <PowerStatusInner
      state="na"
      statusText="Exception error some where"
      error="someError"
      title="N/A"
    />
  </Story>
);

errorStory.story = {
  name: 'Error',
};
