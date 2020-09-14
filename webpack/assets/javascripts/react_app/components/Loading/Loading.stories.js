import React from 'react';
import Story from '../../../../../stories/components/Story';
import Loading from './Loading';

export default {
  title: 'Components/Loading',
};

export const defaultStory = () => (
  <Story>
    <Loading />
  </Story>
);

export const smallText = () => (
  <Story>
    <Loading textSize="sm" />
  </Story>
);

export const noText = () => (
  <Story>
    <Loading showText={false} />
  </Story>
);

export const smallerIconAndText = () => (
  <Story>
    <Loading textSize="sm" iconSize="md" />
  </Story>
);

defaultStory.story = {
  name: 'Default',
};
