import React from 'react';
import { boolean, select } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';

import DiffModal from './DiffModal';
import Story from '../../../../../../stories/components/Story';

export default {
  title: 'Components/DiffModal',
};

export const diffModal = () => (
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
);

diffModal.story = {
  name: 'DiffModal',
};
