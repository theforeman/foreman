import React from 'react';
import { storiesOf } from '@storybook/react';
import Story from '../../../../../../../../stories/components/Story';
import ExportButton from './ExportButton';

storiesOf('Components/ExportButton', module).add('Default', () => (
  <Story>
    <ul>
      <ExportButton url="/" />
    </ul>
  </Story>
));
