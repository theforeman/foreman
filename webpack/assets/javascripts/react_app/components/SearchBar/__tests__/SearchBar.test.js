import React from 'react';
import SearchBar from '../SearchBar';
import { Provider } from 'react-redux';
import store from '../../../redux';
import { SearchBarProps } from '../SearchBar.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders AutoComplete': SearchBarProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    const searchBar = () => (
      <Provider store={store}>
        <SearchBar {...SearchBarProps} />
      </Provider>
    );
    testComponentSnapshotsWithFixtures(searchBar, fixtures);
  });
});
