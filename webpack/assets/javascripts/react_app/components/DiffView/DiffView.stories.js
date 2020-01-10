import React from 'react';
import { text, withKnobs } from '@theforeman/stories';

import DiffContainer from './DiffContainer';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Components|DiffView',
  decorators: [withKnobs],
};

export const diffView = () => (
  <Story narrow>
    <DiffContainer
      oldText={text('Old Text', 'Old Text')}
      newText={text('New Text', 'New Text')}
    />
  </Story>
);

diffView.story = {
  name: 'DiffView',
};
