import React from 'react';
import Story from '../../../../../../../../stories/components/Story';
import ExportButton from './ExportButton';

export default {
  title: 'Components/ExportButton',
};

export const defaultStory = () => (
  <Story>
    <ul>
      <ExportButton url="/" />
    </ul>
  </Story>
);

defaultStory.story = {
  name: 'Default',
};
