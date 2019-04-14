import React from 'react';
import { storiesOf } from '@storybook/react';
import { withKnobs } from '@storybook/addon-knobs';
import DualList from './DualList';
import { props } from './DualList.fixtures';
import Story from '../../../../../stories/components/Story';

storiesOf('Components/DualList', module)
  .addDecorator(withKnobs)
  .add('DualList', () => (
    <Story>
      <DualList {...props} />
    </Story>
  ));
