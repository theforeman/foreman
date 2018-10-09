import React from 'react';
import { storiesOf } from '@storybook/react';
import { boolean, withKnobs, select } from '@storybook/addon-knobs';
import DiffModal from './DiffModal';

storiesOf('Components/DiffModal', module)
  .addDecorator(withKnobs)
  .add('DiffModal', () => (
    <div>
      <DiffModal
        isOpen={boolean('openModal', true)}
        title="DiffModal"
        oldText="Hello there friend"
        newText="Hello friend"
        diffViewType={select(
          'viewType',
          { split: 'split', unified: 'unified' },
          'unified'
        )}
      />
    </div>
  ));
