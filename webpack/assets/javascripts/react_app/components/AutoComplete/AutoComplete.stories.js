import React from 'react';
import { Provider } from 'react-redux';
import { storiesOf } from '@storybook/react';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Store from '../../redux';
import { AutoCompleteProps, API } from './AutoComplete.fixtures';
import Story from '../../../../../stories/components/Story';
import AutoComplete from './index';

storiesOf('Components/AutoComplete', module).add(
  'AutoComplete with mocked data',
  () => {
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
  }
);
