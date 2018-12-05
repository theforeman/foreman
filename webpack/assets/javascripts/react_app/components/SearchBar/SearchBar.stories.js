import React from 'react';
import { Provider } from 'react-redux';
import { storiesOf } from '@storybook/react';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import URI from 'urijs';
import Store from '../../redux';
import SearchBar from './index';
import { SearchBarProps, APImock } from './SearchBar.fixtures';
import Story from '../../../../../stories/components/Story';

const someAutoCompletePath = /^models\/auto_complete_search.*/;
const mock = new MockAdapter(axios);
mock.onGet(someAutoCompletePath).reply(({ url }) => {
  const query = URI.decodeQuery(url.split('search=')[1]);
  const results = APImock[query];
  return [200, results || []];
});

storiesOf('Components/SearchBar', module).add(
  'Search Bar with mocked data',
  () => (
    <Provider store={Store}>
      <Story narrow>
        <h4>Try typing something like: &quot;name = &quot;</h4>
        <SearchBar data={SearchBarProps.data} />
      </Story>
    </Provider>
  )
);
