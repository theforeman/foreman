import React from 'react';
import { storiesOf } from '@storybook/react';
import { text, withKnobs } from '@storybook/addon-knobs';
import DiffContainer from './DiffContainer';

storiesOf('Components/DiffView', module)
  .addDecorator(withKnobs)
  .add('DiffView', () => (
    <div style={{ width: '600px', padding: '30px' }}>
      <DiffContainer
        oldText={text('Old Text', 'Old Text')}
        newText={text('New Text', 'New Text')}
      />
    </div>
  ));
