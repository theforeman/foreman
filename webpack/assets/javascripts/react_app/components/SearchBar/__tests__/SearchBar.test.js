import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import SearchBar from '../SearchBar';
import { SearchBarProps } from '../SearchBar.fixtures';

const fixtures = {
  'renders AutoComplete': SearchBarProps,
};
describe('AutoComplete', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(SearchBar, fixtures);
  });
});
