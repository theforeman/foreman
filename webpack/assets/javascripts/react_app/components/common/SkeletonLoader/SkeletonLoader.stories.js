import React from 'react';
import { boolean, text, withKnobs } from '@theforeman/stories';
import Story from '../../../../../../stories/components/Story';
import SkeletonLoader from '.';

export default {
  title: 'Components|Common|Empty Line',
  decorators: [withKnobs],
};

export const defaultStory = () => (
  <Story>
    <ul>
      <span>
        This will show a Skeleton if the data is loading and N/A if the data has
        finished loading
      </span>
      <br />
      <SkeletonLoader isLoading={boolean('is loading', false)} />
    </ul>
  </Story>
);

defaultStory.story = {
  name: 'Empty Line',
};
