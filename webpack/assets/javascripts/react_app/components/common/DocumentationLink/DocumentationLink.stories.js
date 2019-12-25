import React from 'react';
import { storiesOf, action } from '@theforeman/stories';

import Story from '../../../../../../stories/components/Story';
import DocumentationLink from './index';

storiesOf('Components|DocumentationLink', module).add('Default', () => (
  <Story>
    <ul>
      <DocumentationLink handleClick={action('Link was clicked')} href="#" />
    </ul>
  </Story>
));
