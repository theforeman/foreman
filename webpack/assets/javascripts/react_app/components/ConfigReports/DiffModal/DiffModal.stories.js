import React from 'react';
import {
  storiesOf,
  boolean,
  withKnobs,
  select,
  action,
} from '@theforeman/stories';

import DiffModal from './DiffModal';
import Story from '../../../../../../stories/components/Story';

storiesOf('Components|Diff', module)
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
