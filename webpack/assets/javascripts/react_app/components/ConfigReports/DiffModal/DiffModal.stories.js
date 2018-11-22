import React from 'react';
import { storiesOf } from '@storybook/react';
import { boolean, withKnobs, select } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import DiffModal from './DiffModal';
import Story from '../../../../../../stories/components/Story';

storiesOf('Components/Diff', module)
  .addDecorator(withKnobs)
  .add('DiffModal', () => (
    <Story>
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
        changeViewType={action('changeViewType')}
        toggleModal={action('toggleModal')}
      />
    </Story>
  ));
