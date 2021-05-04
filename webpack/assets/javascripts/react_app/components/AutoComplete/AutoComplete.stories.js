import React from 'react';
import { action } from '@storybook/addon-actions';
import {
  AutoCompleteProps,
  AutoCompletePropsWithData,
} from './AutoComplete.fixtures';
import Story from '../../../../../stories/components/Story';
import AutoComplete from './AutoComplete';

export default {
  title: 'Components/AutoComplete',
};

export const autoCompleteWithMockedData = () => (
  <Story narrow>
    <h4>Try typing something like: &quot;name = &quot;</h4>
    <AutoComplete
      {...AutoCompletePropsWithData}
      getResults={action('get results')}
    />
  </Story>
);

export const autoCompleteWithError = () => (
  <Story narrow>
    <AutoComplete {...AutoCompleteProps} getResults={action('get results')} />
  </Story>
);

autoCompleteWithMockedData.story = {
  name: 'with data',
};

autoCompleteWithError.story = {
  name: 'with error',
};
