import React from 'react';
import { number } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import { MEGABYTES } from './constants';
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
      value={number('Value[B]', 1024 * MEGABYTES)}
      onChange={action('Value was changed')}
      recommendedMaxValue={number('RecommendedMaxValue', 10240 * MEGABYTES)}
      maxValue={number('MaxValue', 20480 * MEGABYTES)}
    />
);
