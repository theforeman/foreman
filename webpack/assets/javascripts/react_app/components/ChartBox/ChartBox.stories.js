import React from 'react';
import ChartBox from './ChartBox';
import mockStoryData from './ChartBox.fixtures';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Components|Charts/ChartBox',
  component: ChartBox,
};

export const Loading = () => (
  <Story narrow>
    <ChartBox
      chart={{ data: [] }}
      noDataMsg="No data here."
      title="Title"
      status="PENDING"
    />
  </Story>
);

export const WithoutData = () => (
  <Story narrow>
    <ChartBox
      type="donut"
      chart={{ data: [] }}
      noDataMsg="No data here"
      title="Title"
      status="RESOLVED"
    />
  </Story>
);

export const WithError = () => (
  <Story narrow>
    <ChartBox
      chart={{ data: [] }}
      title="Title"
      noDataMsg="No data here"
      errorText="Ooops"
      status="ERROR"
    />
  </Story>
);

export const WithDataAndModal = () => (
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
);

WithDataAndModal.story = {
  name: 'With Data + Modal',
};
