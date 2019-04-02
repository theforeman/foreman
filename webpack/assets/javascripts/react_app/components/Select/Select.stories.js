import React from 'react';
import { storiesOf } from '@storybook/react';
import { boolean, withKnobs } from '@storybook/addon-knobs';
import StatefulWrapperSelect from './StatefulWrapperSelect';
import Select from './Select';
import { optionsArray } from './Select.fixtures';

import Story from '../../../../../stories/components/Story';

storiesOf('Components/Select', module)
  .addDecorator(withKnobs)
  .add('Select', () => (
    <Story>
      <div style={{ width: '260px' }}>
        <Select
          options={optionsArray}
          placeholder="Filter..."
          open
          searchValue="one"
          selectedItem={{ id: '3', name: 'selected' }}
          isLoading={boolean('isLoading', false)}
        />
      </div>
    </Story>
  ))
  .add('Stateful Select', () => (
    <Story>
      <div style={{ width: '260px' }}>
        <StatefulWrapperSelect />
      </div>
    </Story>
  ));
