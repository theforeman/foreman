import React from 'react';
import { number, action, text } from '@theforeman/stories';
import CPUCoresInput from './CPUCoresInput';

export default {
  title: 'Components|Form/CPUCoresInput',
  component: CPUCoresInput,
  parameters: {
    centered: { disable: true },
  },
};

export const UseCpuOrCoresInput = () => (
  <CPUCoresInput
    label={text('Label', 'CPUs')}
    defaultValue={number('DefaultValue', 1)}
    recommendedMaxValue={number('RecommendedMaxValue', 10)}
    maxValue={number('MaxValue', 20)}
    minValue={number('MinValue', 1)}
    onChange={action('Value was changed')}
  />
);
