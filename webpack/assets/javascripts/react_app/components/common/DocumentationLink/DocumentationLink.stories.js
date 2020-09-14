import React from 'react';
import { action } from '@storybook/addon-actions';

import Story from '../../../../../../stories/components/Story';
import DocumentationLink from './index';

export default {
  title: 'Components/DocumentationLink',
};

export const defaultStory = () => (
  <Story>
    <ul>
      <DocumentationLink handleClick={action('Link was clicked')} href="#" />
    </ul>
  </Story>
);

defaultStory.story = {
  name: 'Default',
};
