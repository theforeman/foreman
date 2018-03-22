import React from 'react';
import { storiesOf } from '@storybook/react';
import ChartBox from './ChartBox';
import mockStoryData from './ChartBox.fixtures';

storiesOf('Charts', module)
  .add('Loading', () => (
    <ChartBox chart={{ data: [] }} noDataMsg={'No data here'} title="Title" status="PENDING" />
  ))
  .add('Without Data', () => (
    <ChartBox chart={{ data: [] }} noDataMsg={'No data here'} title="Title" status="RESOLVED" />
  ))
  .add('With Error', () => (
    <ChartBox
      chart={{ data: [] }}
      title="Title"
      noDataMsg={'No data here'}
      errorText="Ooops"
      status="ERROR"
    />
  ))
  .add('With Data + Modal', () => (
    <ChartBox
      chart={{ data: mockStoryData.config.data.columns }}
      noDataMsg={mockStoryData.noDataMsg}
      tip={mockStoryData.tip}
      title={mockStoryData.title}
      status="RESOLVED"
    />
  ));
