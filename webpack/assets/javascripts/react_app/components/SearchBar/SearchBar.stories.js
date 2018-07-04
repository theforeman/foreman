import React from 'react';
import { Provider } from 'react-redux';
import { storiesOf } from '@storybook/react';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import URI from 'urijs';
import Store from '../../redux';
import SearchBar from './index';
import { SearchBarProps, APImock } from './SearchBar.fixtures';

const storyStyle = { width: '600px', margin: 'auto', marginTop: '100px' };
const someAutoCompletePath = /^models\/auto_complete_search.*/;
const mock = new MockAdapter(axios);
mock.onGet(someAutoCompletePath).reply(({ url }) => {
  const query = URI.decodeQuery(url.split('search=')[1]);
  const results = APImock[query];
  return [200, results || []];
});

storiesOf('Components/SearchBar', module).add('Search Bar with mocked data', () => (
  <Provider store={Store}>
    <div style={storyStyle}>
      <h4>Try typing something like: "name = "</h4>
      <SearchBar data={SearchBarProps.data} />
    </div>
  </Provider>
));
