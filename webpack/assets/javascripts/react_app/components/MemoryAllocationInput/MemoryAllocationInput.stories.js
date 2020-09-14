import React from 'react';
import { number, text } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import MemoryAllocationInput from './MemoryAllocationInput';

export default {
  title: 'Components/Form/MemoryAllocationInput',
  component: MemoryAllocationInput,
  parameters: {
    centered: { disable: true },
  },
};

export const UseMemoryAllocationInput = () => (
  <MemoryAllocationInput
    label={text('Label', 'Memory')}
    defaultValue={number('DefaultValue', 1024)}
    onChange={action('Value was changed')}
    recommendedMaxValue={number('RecommendedMaxValue', 10240)}
    maxValue={number('MaxValue', 20480)}
  />
);
