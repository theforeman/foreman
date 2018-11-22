import React from 'react';
import { storiesOf } from '@storybook/react';
import { text, withKnobs } from '@storybook/addon-knobs';
import DiffContainer from './DiffContainer';
import Story from '../../../../../stories/components/Story';

storiesOf('Components/Diff', module)
  .addDecorator(withKnobs)
  .add('DiffView', () => (
    <Story narrow>
      <DiffContainer
        oldText={text('Old Text', 'Old Text')}
        newText={text('New Text', 'New Text')}
      />
    </Story>
  ));
