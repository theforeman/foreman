import React from 'react';
import { storiesOf } from '@storybook/react';
import ChartBox from './ChartBox';
import mockStoryData from './ChartBox.fixtures';
import Story from '../../../../../stories/components/Story';

storiesOf('Components/Charts', module)
  .add('Loading', () => (
    <Story narrow>
      <ChartBox
        chart={{ data: [] }}
        noDataMsg="No data here"
        title="Title"
        status="PENDING"
      />
    </Story>
  ))
  .add('Without Data', () => (
    <Story narrow>
      <ChartBox
        type="donut"
        chart={{ data: [] }}
        noDataMsg="No data here"
        title="Title"
        status="RESOLVED"
      />
    </Story>
  ))
  .add('With Error', () => (
    <Story narrow>
      <ChartBox
        chart={{ data: [] }}
        title="Title"
        noDataMsg="No data here"
        errorText="Ooops"
        status="ERROR"
      />
    </Story>
  ))
  .add('With Data + Modal', () => (
    <Story narrow>
      <ChartBox
        type="donut"
        chart={{ data: mockStoryData.config.data.columns }}
        noDataMsg={mockStoryData.noDataMsg}
        tip={mockStoryData.tip}
        title={mockStoryData.title}
        status="RESOLVED"
      />
    </Story>
  ));
