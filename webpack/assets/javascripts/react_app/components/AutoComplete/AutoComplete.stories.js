import React from 'react';
import { Provider } from 'react-redux';
import axios from 'axios';
import { MockAdapter } from '@theforeman/test';
import Store from '../../redux';
import { AutoCompleteProps, API } from './AutoComplete.fixtures';
import Story from '../../../../../stories/components/Story';
import AutoComplete from './index';

export default {
  title: 'Components|AutoComplete',
};

export const autoCompleteWithMockedData = () => {
  const someAutoCompletePath = /^models\/auto_complete_search.*/;
  const mock = new MockAdapter(axios);
  mock.onGet(someAutoCompletePath).reply(
    ({ url }) =>
      new Promise(resolve => {
        const query = url.split('?search=')[1];
        const results = API[query];
        resolve([200, results || []]);
      })
  );

  return (
    <Provider store={Store}>
      <Story narrow>
        <h4>Try typing something like: &quot;name = &quot;</h4>
        <AutoComplete {...AutoCompleteProps} />
      </Story>
    </Provider>
  );
};

autoCompleteWithMockedData.story = {
  name: 'AutoComplete with mocked data',
};
